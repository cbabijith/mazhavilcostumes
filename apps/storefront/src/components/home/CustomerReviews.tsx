import { reviews } from "@/data/homepage";
import { Star, Quote } from "lucide-react";

export default function CustomerReviews() {
  return (
    <section className="bg-white py-8 sm:py-10 md:py-14 px-4 sm:px-6 md:px-12">
      <div className="max-w-[1200px] mx-auto">
        <div className="text-center mb-6 sm:mb-8 md:mb-10">
          <span className="text-[10px] sm:text-xs uppercase tracking-[0.2em] font-bold text-rosegold">
            Testimonials
          </span>
          <h2 className="text-xl sm:text-2xl md:text-3xl font-bold text-heading mt-2">
            Customer Feedback
          </h2>
          <p className="text-xs sm:text-sm text-body mt-2">Real stories from stage performances</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 sm:gap-5 md:gap-6">
          {reviews.map((review) => (
            <div
              key={review.id}
              className="flex flex-col rounded-2xl border border-[#EAEAEA] bg-white p-5 sm:p-6"
            >
              <div className="flex items-center justify-between mb-3">
                <div className="flex gap-0.5">
                  {[...Array(5)].map((_, i) => (
                    <Star
                      key={i}
                      size={14}
                      className={i < review.rating ? "fill-amber-400 text-amber-400" : "text-gray-200"}
                    />
                  ))}
                </div>
                <Quote size={18} className="text-rosegold/20 shrink-0" />
              </div>

              <p className="text-[13px] sm:text-sm text-body leading-relaxed flex-1">
                {review.text}
              </p>

              <div className="mt-4 pt-4 border-t border-[#EAEAEA]">
                <h4 className="text-sm font-semibold text-heading">
                  {review.name}
                </h4>
                <p className="text-[11px] text-rosegold font-medium mt-0.5">
                  {review.occasion}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
