/**
 * Gallery Management Page
 *
 * Professional page to upload, delete, toggle active state, and drag-and-drop sort
 * client-shared costume photos. Follows the exact UI/UX patterns of the monorepo.
 *
 * @module app/dashboard/gallery/page
 */

"use client";

import { Suspense, useState, useMemo, useCallback, useRef } from "react";
import {
  Images,
  Trash2,
  GripVertical,
  Loader2,
  AlertTriangle,
  Eye,
  EyeOff,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { FileUpload } from "@/components/ui/file-upload";
import Modal from "@/components/admin/Modal";
import {
  useGallery,
  useCreateGalleryItem,
  useUpdateGalleryItem,
  useDeleteGalleryItem,
  useReorderGalleryItems,
} from "@/hooks";
import { type GalleryItem } from "@/domain";
import { useAppStore } from "@/stores";
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  DragEndEvent,
} from '@dnd-kit/core';
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  useSortable,
  rectSortingStrategy,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

export default function GalleryPage() {
  return (
    <Suspense fallback={
      <div className="flex items-center justify-center p-12 text-slate-500">
        <Loader2 className="w-6 h-6 animate-spin mr-2" />
        Loading gallery...
      </div>
    }>
      <GalleryContent />
    </Suspense>
  );
}

function GalleryContent() {
  const { data: galleryItems, isLoading } = useGallery();
  const createGalleryItem = useCreateGalleryItem();
  const updateGalleryItem = useUpdateGalleryItem();
  const deleteGalleryItem = useDeleteGalleryItem();
  const reorderGalleryItems = useReorderGalleryItems();
  const { showSuccess } = useAppStore();

  const [uploadValue, setUploadValue] = useState<string[]>([]);
  const [deleteDialog, setDeleteDialog] = useState<{ open: boolean; item: GalleryItem | null }>({
    open: false,
    item: null,
  });

  const successCountRef = useRef(0);

  const sortedItems = useMemo(() => {
    if (!galleryItems) return [];
    return [...galleryItems].sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0));
  }, [galleryItems]);

  const handleUploadChange = async (urls: string[]) => {
    // urls is the cumulative array from FileUpload. We find new ones.
    const existingUrls = galleryItems?.map(item => item.image_url) || [];
    const newUrls = urls.filter(url => !existingUrls.includes(url));

    if (newUrls.length === 0) return;

    let nextSortOrder = (galleryItems?.length || 0) + 1;

    for (const url of newUrls) {
      try {
        await createGalleryItem.mutateAsync({
          image_url: url,
          is_active: true,
          sort_order: nextSortOrder++,
          silent: true, // Always silent so we can show a single summary toast at the end of the batch
        } as any);
        successCountRef.current++;
      } catch (err) {
        console.error("Failed to save gallery item:", err);
      }
    }

    // Reset the uploader state
    setUploadValue([]);
  };

  const handleUploadComplete = () => {
    if (successCountRef.current > 0) {
      showSuccess(`Successfully uploaded and saved ${successCountRef.current} photo(s) to gallery`);
      successCountRef.current = 0; // reset
    }
  };

  const handleToggleActive = async (item: GalleryItem) => {
    try {
      await updateGalleryItem.mutateAsync({
        id: item.id,
        data: { is_active: !item.is_active },
      });
    } catch (err) {
      console.error("Failed to toggle item status:", err);
    }
  };

  const handleDeleteClick = (item: GalleryItem) => {
    setDeleteDialog({ open: true, item });
  };

  const handleConfirmDelete = async () => {
    if (deleteDialog.item) {
      try {
        await deleteGalleryItem.mutateAsync(deleteDialog.item.id);
      } catch (err) {
        console.error("Failed to delete gallery item:", err);
      } finally {
        setDeleteDialog({ open: false, item: null });
      }
    }
  };

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8,
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  const handleDragEnd = useCallback((event: DragEndEvent) => {
    const { active, over } = event;

    if (over && active.id !== over.id) {
      const oldIndex = sortedItems.findIndex((item) => item.id === active.id);
      const newIndex = sortedItems.findIndex((item) => item.id === over.id);

      const reordered = arrayMove(sortedItems, oldIndex, newIndex);

      // Re-calculate all sort orders sequentially
      const updates = reordered.map((item, index) => ({
        id: item.id,
        sort_order: index + 1,
      }));

      reorderGalleryItems.mutate(updates);
    }
  }, [sortedItems, reorderGalleryItems]);

  const stats = useMemo(() => {
    const total = sortedItems.length;
    const active = sortedItems.filter(item => item.is_active).length;
    return { total, active };
  }, [sortedItems]);

  const showShimmer = isLoading;

  return (
    <div className="space-y-6 pb-12">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Costume Gallery</h1>
          <p className="text-sm text-slate-500 mt-1 flex items-center gap-2 flex-wrap">
            <Images className="w-4 h-4 text-slate-400" />
            <span>Upload and manage costume photos shared by your clients</span>
            <span>• {stats.total} total ({stats.active} active)</span>
          </p>
        </div>
      </div>

      {/* Upload Zone */}
      <Card className="shadow-sm border-slate-200 bg-white">
        <CardContent className="p-5 space-y-3">
          <h3 className="text-sm font-semibold text-slate-900">Upload Costume Photos</h3>
          <FileUpload
            accept="image/*"
            multiple={true}
            maxFiles={200}
            maxSize={100 * 1024 * 1024}
            compress={true}
            folder="gallery"
            value={uploadValue}
            onChange={handleUploadChange}
            onUploadComplete={handleUploadComplete}
            helperText="Drag & drop or click to upload multiple client photos (compressed, max 100MB per file)"
            disabled={createGalleryItem.isPending}
          />
        </CardContent>
      </Card>

      {/* Gallery Photos Grid */}
      <Card className="shadow-sm border-slate-200 bg-white p-6">
        {showShimmer ? (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
            {[...Array(8)].map((_, i) => (
              <div key={i} className="aspect-square bg-slate-100 rounded-xl animate-pulse" />
            ))}
          </div>
        ) : sortedItems.length === 0 ? (
          <div className="text-center py-16">
            <Images className="w-12 h-12 text-slate-300 mx-auto mb-3" />
            <h3 className="text-lg font-semibold text-slate-900 mb-1">No Costume Photos Yet</h3>
            <p className="text-sm text-slate-500 max-w-sm mx-auto">
              Upload client-shared costume photos using the box above. They will show on your storefront immediately.
            </p>
          </div>
        ) : (
          <DndContext
            sensors={sensors}
            collisionDetection={closestCenter}
            onDragEnd={handleDragEnd}
          >
            <SortableContext
              items={sortedItems.map(item => item.id)}
              strategy={rectSortingStrategy}
            >
              <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
                {sortedItems.map((item) => (
                  <SortableGalleryCard
                    key={item.id}
                    item={item}
                    onDelete={() => handleDeleteClick(item)}
                    onToggleActive={() => handleToggleActive(item)}
                    isUpdating={updateGalleryItem.isPending && updateGalleryItem.variables?.id === item.id}
                  />
                ))}
              </div>
            </SortableContext>
          </DndContext>
        )}
      </Card>

      {/* Delete Confirmation Modal */}
      <Modal
        open={deleteDialog.open}
        onClose={() => setDeleteDialog({ open: false, item: null })}
        title="Delete Gallery Photo"
        maxWidth="max-w-md"
      >
        <div className="p-6">
          <div className="flex items-start gap-4 mb-6">
            <div className="w-10 h-10 rounded-full bg-red-50 flex items-center justify-center shrink-0">
              <AlertTriangle className="w-5 h-5 text-red-600" />
            </div>
            <div>
              <h4 className="text-sm font-semibold text-slate-900 mb-1">Confirm Deletion</h4>
              <p className="text-sm text-slate-600 leading-relaxed">
                Are you sure you want to permanently delete this costume photo? This action cannot be undone and it will be removed from the storefront.
              </p>
            </div>
          </div>
          {deleteDialog.item && (
            <div className="w-32 h-32 mx-auto rounded-lg overflow-hidden border border-slate-200 mb-6 bg-slate-50">
              <img src={deleteDialog.item.image_url} alt="To delete" className="w-full h-full object-cover" />
            </div>
          )}
          <div className="flex justify-end gap-3 pt-4 border-t border-slate-100">
            <Button variant="outline" onClick={() => setDeleteDialog({ open: false, item: null })} className="border-slate-200">Cancel</Button>
            <Button variant="destructive" onClick={handleConfirmDelete} disabled={deleteGalleryItem.isPending}>
              {deleteGalleryItem.isPending ? "Deleting..." : "Delete Photo"}
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

interface SortableGalleryCardProps {
  item: GalleryItem;
  onDelete: () => void;
  onToggleActive: () => void;
  isUpdating?: boolean;
}

function SortableGalleryCard({ item, onDelete, onToggleActive, isUpdating }: SortableGalleryCardProps) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: item.id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
    zIndex: isDragging ? 50 : 'auto',
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      className="group relative aspect-square rounded-xl overflow-hidden border border-slate-200 bg-slate-50 shadow-sm hover:shadow-md transition-all flex flex-col"
    >
      {/* Costume Image */}
      <img
        src={item.image_url}
        alt="Client Costume Photo"
        className="w-full h-full object-cover"
        loading="lazy"
      />

      {/* Dark overlay on hover */}
      <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity duration-200" />

      {/* Drag Handle & Delete Button */}
      <div className="absolute top-2 right-2 left-2 flex items-center justify-between opacity-0 group-hover:opacity-100 transition-opacity duration-200 z-10">
        <button
          type="button"
          {...attributes}
          {...listeners}
          className="cursor-grab active:cursor-grabbing p-1.5 bg-white/90 hover:bg-white text-slate-700 rounded-lg shadow-sm hover:scale-105 transition-transform"
          title="Drag to sort"
        >
          <GripVertical className="w-4 h-4" />
        </button>
        <button
          type="button"
          onClick={onDelete}
          className="p-1.5 bg-red-600 hover:bg-red-700 text-white rounded-lg shadow-sm hover:scale-105 transition-transform"
          title="Delete costume photo"
        >
          <Trash2 className="w-4 h-4" />
        </button>
      </div>

      {/* Active/Inactive Badge & Switch */}
      <div className="absolute bottom-2 left-2 right-2 flex items-center justify-between z-10">
        {/* Toggle Indicator Badge */}
        <Badge
          className={`text-[10px] font-semibold px-2 py-0.5 rounded-full select-none shadow-sm ${
            item.is_active
              ? "bg-emerald-50 text-emerald-700 border border-emerald-200/50"
              : "bg-slate-100 text-slate-600 border border-slate-200/50"
          }`}
        >
          {item.is_active ? "Active" : "Hidden"}
        </Badge>

        {/* Toggle Switch */}
        <button
          type="button"
          onClick={onToggleActive}
          disabled={isUpdating}
          className="relative inline-flex items-center cursor-pointer p-1 rounded-full bg-white/90 hover:bg-white shadow-sm hover:scale-105 transition-all"
          title={item.is_active ? "Hide from Storefront" : "Show on Storefront"}
        >
          {isUpdating ? (
            <Loader2 className="w-4 h-4 animate-spin text-slate-500" />
          ) : item.is_active ? (
            <Eye className="w-4 h-4 text-emerald-600" />
          ) : (
            <EyeOff className="w-4 h-4 text-slate-400" />
          )}
        </button>
      </div>
    </div>
  );
}
