/**
 * FileUpload Component
 *
 * Reusable drag-and-drop file upload with image preview, validation,
 * and R2 integration. Supports single and multiple file modes.
 *
 * Used by CategoryForm (single image), ProductForm (multiple images),
 * and BannerForm (web + mobile images).
 *
 * @module components/ui/file-upload
 */

"use client";

import * as React from "react";
import { useCallback, useState, useRef, useEffect } from "react";
import { cn } from "@/lib/utils";
import { Upload, X, FileVideo, Loader2, AlertCircle, Clock } from "lucide-react";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface UploadedFile {
  /** Public URL of the uploaded file (from R2) */
  url: string;
  /** S3 object key for future reference / deletion */
  key?: string;
}

export interface FileUploadProps {
  /** Accepted MIME types (e.g., "image/*", "video/*") */
  accept?: string;
  /** Allow multiple files */
  multiple?: boolean;
  /** Maximum number of files (only relevant when multiple=true) */
  maxFiles?: number;
  /** Maximum file size in bytes (default: 5MB) */
  maxSize?: number;
  /** R2 folder to upload to (e.g., "categories", "products", "banners") */
  folder?: string;
  /** Whether to upload immediately on file selection (default: true) */
  uploadImmediately?: boolean;
  /** Already-uploaded file URLs (for edit mode pre-population) */
  value?: string[];
  /** Callback when uploaded files change (array of URLs) */
  onChange?: (urls: string[]) => void;
  /** Callback when files are selected but not yet uploaded (for deferred upload) */
  onFilesSelected?: (files: File[]) => void;
  /** Label displayed above the drop zone */
  label?: string;
  /** Helper text displayed below the drop zone */
  helperText?: string;
  /** Disable the component */
  disabled?: boolean;
  /** Additional class names for the wrapper */
  className?: string;
  /** Whether to compress images client-side before upload (default: true) */
  compress?: boolean;
  /** Callback triggered when all files in the current upload queue have finished processing */
  onUploadComplete?: () => void;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function formatFileSize(bytes: number): string {
  if (bytes === 0) return "0 B";
  const k = 1024;
  const sizes = ["B", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i]}`;
}

/**
 * Compress an image file client-side using Canvas API.
 * Resizes to max 1200px wide and iteratively reduces quality
 * until the output is under the target size (default 100KB).
 */
const TARGET_SIZE_BYTES = 100 * 1024; // 100KB
const MAX_DIMENSION = 1200;

async function compressImage(file: File): Promise<File> {
  // Skip non-image files
  if (!file.type.startsWith("image/")) return file;

  return new Promise((resolve) => {
    const img = new window.Image();
    const url = URL.createObjectURL(file);

    img.onload = () => {
      URL.revokeObjectURL(url);

      // Calculate dimensions (max 1200px on longest side)
      let { width, height } = img;
      if (width > MAX_DIMENSION || height > MAX_DIMENSION) {
        const ratio = Math.min(MAX_DIMENSION / width, MAX_DIMENSION / height);
        width = Math.round(width * ratio);
        height = Math.round(height * ratio);
      }

      const canvas = document.createElement("canvas");
      canvas.width = width;
      canvas.height = height;
      const ctx = canvas.getContext("2d")!;
      ctx.drawImage(img, 0, 0, width, height);

      // Try WebP first, fall back to JPEG
      const outputType = "image/webp";

      // Iteratively reduce quality until under target
      let quality = 0.8;
      const tryCompress = () => {
        canvas.toBlob(
          (blob) => {
            if (!blob) {
              resolve(file); // fallback to original
              return;
            }

            if (blob.size <= TARGET_SIZE_BYTES || quality <= 0.1) {
              // Good enough — create a new File
              const ext = outputType === "image/webp" ? ".webp" : ".jpg";
              const newName = file.name.replace(/\.[^.]+$/, ext);
              resolve(new File([blob], newName, { type: outputType }));
            } else {
              // Reduce quality and try again
              quality -= 0.1;
              tryCompress();
            }
          },
          outputType,
          quality
        );
      };

      tryCompress();
    };

    img.onerror = () => {
      URL.revokeObjectURL(url);
      resolve(file); // fallback to original on error
    };

    img.src = url;
  });
}

function isHeicFile(file: File): boolean {
  const fileName = file.name.toLowerCase();
  return fileName.endsWith(".heic") || fileName.endsWith(".heif");
}

// ---------------------------------------------------------------------------
// Sub-components
// ---------------------------------------------------------------------------

interface PreviewItemProps {
  url: string;
  isVideo?: boolean;
  onRemove: () => void;
  disabled?: boolean;
}

function PreviewItem({ url, isVideo, onRemove, disabled }: PreviewItemProps) {
  return (
    <div className="group relative w-24 h-24">
      <div className="w-full h-full rounded-xl overflow-hidden border border-slate-200 bg-slate-50">
        {isVideo ? (
          <div className="w-full h-full flex flex-col items-center justify-center bg-slate-100">
            <FileVideo className="w-8 h-8 text-slate-400" />
            <span className="text-[10px] text-slate-400 mt-1">Video</span>
          </div>
        ) : (
          <img
            src={url}
            alt="Preview"
            className="w-full h-full object-cover"
          />
        )}
      </div>
      {!disabled && (
        <button
          type="button"
          onClick={onRemove}
          className="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full flex items-center justify-center hover:bg-red-600 shadow-sm z-10"
        >
          <X className="w-3 h-3" />
        </button>
      )}
    </div>
  );
}

export interface QueueItem {
  id: string;
  file: File;
  name: string;
  size: number;
  status: 'waiting' | 'compressing' | 'uploading' | 'error';
}

interface QueuePreviewItemProps {
  item: QueueItem;
  onRemove: () => void;
  disabled?: boolean;
}

function QueuePreviewItem({ item, onRemove, disabled }: QueuePreviewItemProps) {
  const statusLabels = {
    waiting: "Waiting...",
    compressing: "Compressing...",
    uploading: "Uploading...",
    error: "Failed",
  };

  const statusColors = {
    waiting: "border-slate-200 bg-slate-50/50 text-slate-400 dark:border-slate-800 dark:bg-slate-900/20",
    compressing: "border-blue-300 bg-blue-50/50 text-blue-600 dark:border-blue-800 dark:bg-blue-950/20",
    uploading: "border-primary/40 bg-primary/5 text-primary",
    error: "border-red-300 bg-red-50/50 text-red-600 dark:border-red-900/50 dark:bg-red-950/20",
  };

  const isProcessing = item.status === 'compressing' || item.status === 'uploading';

  return (
    <div className={cn(
      "group relative w-24 h-24 rounded-xl border-2 border-dashed flex flex-col items-center justify-center p-2 text-center transition-all",
      statusColors[item.status]
    )}>
      {item.status === 'error' ? (
        <AlertCircle className="w-5 h-5 text-red-500 mb-1" />
      ) : isProcessing ? (
        <Loader2 className="w-5 h-5 text-current animate-spin mb-1" />
      ) : (
        <Clock className="w-5 h-5 text-slate-400 mb-1" />
      )}
      
      <span className="text-[10px] font-medium truncate w-full px-1">
        {item.name}
      </span>
      <span className="text-[9px] opacity-75 mt-0.5">
        {statusLabels[item.status]}
      </span>

      {!disabled && (
        <button
          type="button"
          onClick={onRemove}
          className="absolute -top-2 -right-2 w-5 h-5 bg-red-500 text-white rounded-full flex items-center justify-center hover:bg-red-600 shadow-sm z-10"
        >
          <X className="w-3 h-3" />
        </button>
      )}
    </div>
  );
}

// ---------------------------------------------------------------------------
// Main Component
// ---------------------------------------------------------------------------

const FileUpload = React.forwardRef<HTMLDivElement, FileUploadProps>(
  (
    {
      accept = "image/*",
      multiple = false,
      maxFiles = 10,
      maxSize = 20 * 1024 * 1024,
      folder = "uploads",
      uploadImmediately = true,
      value = [],
      onChange,
      onFilesSelected,
      label,
      helperText,
      disabled = false,
      className,
      compress = true,
      onUploadComplete,
    },
    ref
  ) => {
    const inputRef = useRef<HTMLInputElement>(null);
    const [isDragging, setIsDragging] = useState(false);
    const [uploadQueue, setUploadQueue] = useState<QueueItem[]>([]);
    const [error, setError] = useState<string | null>(null);

    // Refs to store latest values to avoid React state closure stale references in async queue loop
    const queueRef = useRef<QueueItem[]>([]);
    queueRef.current = uploadQueue;

    const valueRef = useRef<string[]>(value);
    valueRef.current = value;

    // Maximum files the user can still add
    const remainingSlots = multiple ? maxFiles - value.length : value.length === 0 ? 1 : 0;
    const canAddMore = remainingSlots > 0 && !disabled;

    // ------------------------------------------------------------------
    // Validation
    // ------------------------------------------------------------------

    const validateFiles = useCallback(
      (files: File[]): { valid: File[]; errors: string[] } => {
        const valid: File[] = [];
        const errors: string[] = [];

        for (const file of files) {
          // Check file type against accept string
          if (accept !== "*") {
            const acceptTypes = accept.split(",").map((t) => t.trim());
            const matches = acceptTypes.some((type) => {
              if (type.endsWith("/*")) {
                return file.type.startsWith(type.replace("/*", "/"));
              }
              return file.type === type;
            });

            // Allow HEIC files by extension even if MIME type is not recognized
            const isHeic = isHeicFile(file);
            const isImageAccept = acceptTypes.some(t => t === "image/*" || t === "image/heic" || t === "image/heif");

            if (!matches && !(isHeic && isImageAccept)) {
              errors.push(`"${file.name}" is not an accepted file type`);
              continue;
            }
          }

          // Check file size
          if (file.size > maxSize) {
            errors.push(
              `"${file.name}" exceeds ${formatFileSize(maxSize)} limit (${formatFileSize(file.size)})`
            );
            continue;
          }

          valid.push(file);
        }

        // Check max files
        if (valid.length > remainingSlots) {
          errors.push(
            `Can only add ${remainingSlots} more file${remainingSlots === 1 ? "" : "s"} (max ${maxFiles})`
          );
          return { valid: valid.slice(0, remainingSlots), errors };
        }

        return { valid, errors };
      },
      [accept, maxSize, maxFiles, remainingSlots]
    );

    // ------------------------------------------------------------------
    // Upload to R2
    // ------------------------------------------------------------------

    const uploadToR2 = useCallback(
      async (file: File): Promise<string | null> => {
        try {
          const formData = new FormData();
          formData.append("file", file);
          formData.append("folder", folder);

          const res = await fetch("/api/upload", {
            method: "POST",
            body: formData,
          });

          if (!res.ok) {
            throw new Error(`Upload failed: ${res.statusText}`);
          }

          const json = await res.json();
          // Support both legacy { url } and standard apiSuccess { data: { url } }
          return json.data?.url || json.url;
        } catch (err) {
          console.error("Upload error:", err);
          return null;
        }
      },
      [folder]
    );

    // ------------------------------------------------------------------
    // Handle file selection
    // ------------------------------------------------------------------

    const processQueueItem = useCallback(
      async (itemId: string) => {
        const item = queueRef.current.find((i) => i.id === itemId);
        if (!item) return;

        try {
          let fileToUpload = item.file;

          // Step 1: Compress image if enabled
          if (compress && item.file.type.startsWith("image/")) {
            setUploadQueue((prev) =>
              prev.map((i) => (i.id === itemId ? { ...i, status: "compressing" } : i))
            );
            fileToUpload = await compressImage(item.file);
          }

          // Step 2: Upload to R2
          setUploadQueue((prev) =>
            prev.map((i) => (i.id === itemId ? { ...i, status: "uploading" } : i))
          );

          const url = await uploadToR2(fileToUpload);
          if (!url) {
            throw new Error(`Failed to upload "${item.file.name}"`);
          }

          // Step 3: Success! Append to parent value immediately
          const newValue = multiple
            ? [...valueRef.current, url]
            : [url];
          
          onChange?.(newValue);

          // Step 4: Remove from queue
          setUploadQueue((prev) => prev.filter((i) => i.id !== itemId));
        } catch (err) {
          console.error("Queue upload error:", err);
          setError(err instanceof Error ? err.message : `Failed to upload "${item.name}"`);
          
          setUploadQueue((prev) =>
            prev.map((i) => (i.id === itemId ? { ...i, status: "error" } : i))
          );
        }
      },
      [compress, uploadToR2, multiple, onChange]
    );

    // Cancel / remove item from queue
    const handleCancelQueueItem = useCallback((itemId: string) => {
      setUploadQueue((prev) => prev.filter((i) => i.id !== itemId));
    }, []);

    // Queue Processor: Reacts to changes in uploadQueue
    useEffect(() => {
      // Don't start another process if one is already compressing or uploading
      const active = uploadQueue.some((i) => i.status === "compressing" || i.status === "uploading");
      if (active) return;

      // Find the next waiting item
      const nextItem = uploadQueue.find((i) => i.status === "waiting");
      if (nextItem) {
        processQueueItem(nextItem.id);
      }
    }, [uploadQueue, processQueueItem]);

    const wasUploadingRef = useRef(false);
    useEffect(() => {
      const activeCount = uploadQueue.filter(
        (i) => i.status === "compressing" || i.status === "uploading" || i.status === "waiting"
      ).length;
      const isCurrentlyUploading = activeCount > 0;

      if (wasUploadingRef.current && !isCurrentlyUploading) {
        onUploadComplete?.();
      }
      wasUploadingRef.current = isCurrentlyUploading;
    }, [uploadQueue, onUploadComplete]);

    const handleFiles = useCallback(
      async (fileList: FileList | File[]) => {
        const files = Array.from(fileList);
        if (files.length === 0) return;

        setError(null);

        const { valid, errors } = validateFiles(files);

        if (errors.length > 0) {
          setError(errors[0]);
        }

        if (valid.length === 0) return;

        // Deferred upload mode — let parent handle upload
        if (!uploadImmediately) {
          onFilesSelected?.(valid);
          return;
        }

        // Immediate upload mode — queue files and process them sequentially
        const newItems: QueueItem[] = valid.map((file, idx) => ({
          id: `${file.name}-${Date.now()}-${idx}`,
          file,
          name: file.name,
          size: file.size,
          status: "waiting",
        }));

        setUploadQueue((prev) => [...prev, ...newItems]);
      },
      [validateFiles, uploadImmediately, onFilesSelected]
    );

    // ------------------------------------------------------------------
    // Remove a file
    // ------------------------------------------------------------------

    const handleRemove = useCallback(
      (index: number) => {
        const newValue = value.filter((_, i) => i !== index);
        onChange?.(newValue);
      },
      [value, onChange]
    );

    // ------------------------------------------------------------------
    // Drag & Drop handlers
    // ------------------------------------------------------------------

    const handleDragOver = useCallback(
      (e: React.DragEvent) => {
        e.preventDefault();
        e.stopPropagation();
        if (canAddMore) setIsDragging(true);
      },
      [canAddMore]
    );

    const handleDragLeave = useCallback((e: React.DragEvent) => {
      e.preventDefault();
      e.stopPropagation();
      setIsDragging(false);
    }, []);

    const handleDrop = useCallback(
      (e: React.DragEvent) => {
        e.preventDefault();
        e.stopPropagation();
        setIsDragging(false);

        if (!canAddMore) return;

        const files = e.dataTransfer.files;
        handleFiles(files);
      },
      [canAddMore, handleFiles]
    );

    // ------------------------------------------------------------------
    // Click to browse
    // ------------------------------------------------------------------

    const handleClick = useCallback(() => {
      if (canAddMore) {
        inputRef.current?.click();
      }
    }, [canAddMore]);

    const handleInputChange = useCallback(
      (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files) {
          handleFiles(e.target.files);
        }
        // Reset input so selecting the same file again triggers onChange
        e.target.value = "";
      },
      [handleFiles]
    );

    // ------------------------------------------------------------------
    // Determine if a URL is a video
    // ------------------------------------------------------------------

    const isVideoUrl = (url: string) => {
      const videoExts = [".mp4", ".webm", ".mov", ".avi", ".mkv"];
      return videoExts.some((ext) => url.toLowerCase().includes(ext));
    };

    // ------------------------------------------------------------------
    // Render
    // ------------------------------------------------------------------

    const isUploading = uploadQueue.some(
      (i) => i.status === "compressing" || i.status === "uploading" || i.status === "waiting"
    );
    const hasFiles = value.length > 0 || uploadQueue.length > 0;

    return (
      <div ref={ref} className={cn("space-y-2", className)}>
        {/* Label */}
        {label && (
          <label className="text-sm font-semibold text-slate-700 block">
            {label}
          </label>
        )}

        {/* Previews */}
        {hasFiles && (
          <div className="flex flex-wrap gap-3">
            {value.map((url, index) => (
              <PreviewItem
                key={url + index}
                url={url}
                isVideo={isVideoUrl(url)}
                onRemove={() => handleRemove(index)}
                disabled={disabled}
              />
            ))}
            {uploadQueue.map((item) => (
              <QueuePreviewItem
                key={item.id}
                item={item}
                onRemove={() => handleCancelQueueItem(item.id)}
                disabled={disabled}
              />
            ))}
          </div>
        )}

        {/* Drop zone */}
        {canAddMore && (
          <div
            role="button"
            tabIndex={0}
            onClick={handleClick}
            onKeyDown={(e) => {
              if (e.key === "Enter" || e.key === " ") handleClick();
            }}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
            onDrop={handleDrop}
            className={cn(
              "relative flex flex-col items-center justify-center gap-2 rounded-xl border-2 border-dashed px-6 py-8 cursor-pointer transition-all",
              isDragging
                ? "border-primary bg-primary/5 scale-[1.01]"
                : "border-slate-300 bg-slate-50 hover:border-slate-400 hover:bg-slate-100",
              isUploading && "pointer-events-none opacity-60",
              disabled && "pointer-events-none opacity-50 cursor-not-allowed"
            )}
          >
            {isUploading ? (
              <>
                <Loader2 className="w-8 h-8 text-primary animate-spin" />
                <p className="text-sm text-primary font-medium">
                  Uploading {uploadQueue.filter((i) => i.status !== "error").length} file(s)…
                </p>
              </>
            ) : (
              <>
                <div className="w-12 h-12 rounded-full bg-slate-200 flex items-center justify-center">
                  <Upload className="w-5 h-5 text-slate-500" />
                </div>
                <div className="text-center">
                  <p className="text-sm font-medium text-slate-700">
                    <span className="text-primary">Click to upload</span> or drag and drop
                  </p>
                  <p className="text-xs text-slate-500 mt-1">
                    {accept === "image/*"
                      ? "PNG, JPG, WebP, HEIC"
                      : accept === "image/*,video/*"
                      ? "PNG, JPG, WebP, HEIC, MP4"
                      : accept}{" "}
                    up to {formatFileSize(maxSize)}
                    {multiple && ` · Max ${maxFiles} files`}
                  </p>
                </div>
              </>
            )}

            {/* Hidden file input */}
            <input
              ref={inputRef}
              type="file"
              accept={accept}
              multiple={multiple}
              onChange={handleInputChange}
              className="hidden"
              disabled={disabled || isUploading}
            />
          </div>
        )}

        {/* Error message */}
        {error && (
          <div className="flex items-center gap-2 text-sm text-red-600">
            <AlertCircle className="w-4 h-4 flex-shrink-0" />
            <span>{error}</span>
          </div>
        )}

        {/* Helper text */}
        {helperText && !error && (
          <p className="text-xs text-slate-500">{helperText}</p>
        )}
      </div>
    );
  }
);

FileUpload.displayName = "FileUpload";

export { FileUpload };
