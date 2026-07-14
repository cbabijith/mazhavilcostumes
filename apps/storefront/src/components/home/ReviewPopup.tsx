"use client";

import { useEffect, useState } from "react";
import { Star, X, MapPin } from "lucide-react";

export default function ReviewPopup() {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    // Check if URL has ?showReview=true to force-show the popup
    const urlParams = new URLSearchParams(window.location.search);
    const forceShow = urlParams.get("showReview") === "true";

    // Check if the user has already interacted with the review popup
    const reviewStatus = localStorage.getItem("mazhavil_review_status");
    if (!forceShow && (reviewStatus === "reviewed" || reviewStatus === "dismissed")) {
      return;
    }

    // Show the popup after a 3-second delay
    const timer = setTimeout(() => {
      setIsVisible(true);
    }, 3000);

    return () => clearTimeout(timer);
  }, []);

  const handleReviewClick = () => {
    localStorage.setItem("mazhavil_review_status", "reviewed");
    setIsVisible(false);
    window.open(
      "https://www.google.com/maps/place/Mazhavil+Dance+Costumes/@8.4813229,76.9651016,190m/data=!3m1!1e3!4m14!1m5!3m4!2zOMKwMjgnNTIuNCJOIDc2wrA1Nyc1NC4yIkU!8m2!3d8.481222!4d76.965056!3m7!1s0x3b05baffdb11f17d:0x33294c74d75f5173!8m2!3d8.4813169!4d76.9650347!9m1!1b1!16s%2Fg%2F11c4bghg8f?entry=ttu",
      "_blank",
      "noopener,noreferrer"
    );
  };

  const handleDismiss = () => {
    localStorage.setItem("mazhavil_review_status", "dismissed");
    setIsVisible(false);
  };

  if (!isVisible) return null;

  return (
    <div className="fixed bottom-24 sm:bottom-6 right-4 sm:right-6 z-50 max-w-sm w-[calc(100%-2rem)] sm:w-full animate-fadeInUp">
      <div className="bg-white border-t-2 border-t-[#E6C79C] border border-border-silk/80 shadow-silk rounded-2xl p-6 relative overflow-hidden">
        {/* Subtle decorative glow */}
        <div className="absolute -top-12 -right-12 w-24 h-24 rounded-full bg-rosegold/10 blur-xl pointer-events-none" />

        {/* Close Button */}
        <button
          onClick={handleDismiss}
          className="absolute top-4 right-4 text-body/40 hover:text-rosegold transition-colors rounded-full p-1 hover:bg-silk"
          aria-label="Close review invitation"
        >
          <X size={16} />
        </button>

        <div className="flex flex-col gap-3">
          {/* Header Row */}
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-full bg-rosegold/10 flex items-center justify-center text-rosegold">
              <MapPin size={16} />
            </div>
            <span className="text-[10px] uppercase tracking-[0.2em] font-bold text-rosegold">
              Google Review
            </span>
          </div>

          {/* Star Rating Display */}
          <div className="flex gap-0.5 mt-1">
            {[...Array(5)].map((_, i) => (
              <Star
                key={i}
                size={16}
                className="fill-amber-400 text-amber-400"
              />
            ))}
          </div>

          {/* Title & Body */}
          <div className="mt-1">
            <h3 className="text-base font-bold text-heading font-serif leading-tight">
              Enjoying Mazhavil Costumes?
            </h3>
            <p className="text-xs text-body font-light leading-relaxed mt-1.5">
              Help other performers and dancers discover our collections by sharing your experience on Google Maps. It only takes a minute!
            </p>
          </div>

          {/* Actions */}
          <div className="flex items-center gap-3 mt-3 pt-2">
            <button
              onClick={handleReviewClick}
              className="flex-1 py-2 px-4 rounded-xl text-xs font-semibold text-white bg-gradient-to-r from-rosegold to-rosegold-light hover:from-rosegold-dark hover:to-rosegold shadow-sm transition-all duration-300 hover:shadow"
            >
              Write a Review
            </button>
            <button
              onClick={handleDismiss}
              className="py-2 px-3 rounded-xl text-xs font-medium text-body/60 hover:text-body border border-border-silk bg-silk/40 hover:bg-silk/80 transition-colors"
            >
              Maybe Later
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
