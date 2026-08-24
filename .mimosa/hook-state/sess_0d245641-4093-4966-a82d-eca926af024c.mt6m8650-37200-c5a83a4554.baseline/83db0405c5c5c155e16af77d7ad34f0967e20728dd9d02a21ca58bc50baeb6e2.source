import { Search, Calendar, MessageCircle } from "lucide-react";

const steps = [
  {
    icon: Search,
    title: "Browse",
    desc: "Explore our collection of premium costumes.",
  },
  {
    icon: Calendar,
    title: "Pick Dates",
    desc: "Select the date for your special event.",
  },
  {
    icon: MessageCircle,
    title: "WhatsApp Order",
    desc: "Continue your order through WhatsApp with selected date and product.",
  },
];

export default function HowItWorks() {
  return (
    <section className="bg-white py-8 sm:py-10 md:py-14 px-4 sm:px-6 md:px-12">
      <div className="max-w-[1200px] mx-auto">
        <div className="text-center mb-6 sm:mb-8 md:mb-10">
          <span className="text-[10px] sm:text-xs uppercase tracking-[0.2em] font-bold text-rosegold">
            Our Process
          </span>
          <h2 className="text-xl sm:text-2xl md:text-3xl font-bold text-heading mt-2">
            How it Works
          </h2>
          <p className="text-xs sm:text-sm text-body mt-2">Simple steps to elegance</p>
        </div>

        <div className="flex flex-col sm:flex-row gap-4 sm:gap-6 md:gap-8">
          {steps.map((step, index) => (
            <div
              key={index}
              className="flex items-center gap-4 sm:flex-col sm:items-center sm:text-center sm:gap-3 md:gap-4 flex-1"
            >
              <div className="relative shrink-0">
                <div className="w-12 h-12 sm:w-16 sm:h-16 md:w-18 md:h-18 rounded-2xl bg-rosegold/10 flex items-center justify-center">
                  <step.icon
                    className="text-rosegold"
                    size={22}
                    strokeWidth={1.8}
                  />
                </div>
                <span className="absolute -top-1.5 -right-1.5 w-5 h-5 sm:w-6 sm:h-6 rounded-full bg-rosegold text-white text-[9px] sm:text-[10px] font-bold flex items-center justify-center">
                  {index + 1}
                </span>
              </div>

              <div className="sm:mt-2">
                <h3 className="text-sm sm:text-base md:text-lg font-semibold text-heading leading-tight">
                  {step.title}
                </h3>
                <p className="text-[11px] sm:text-[12px] md:text-[13px] text-body leading-relaxed mt-1 sm:mt-1.5 max-w-[200px] sm:mx-auto">
                  {step.desc}
                </p>
              </div>

              {index < steps.length - 1 && (
                <div className="hidden sm:block w-8 md:w-12 h-px bg-border-silk sm:absolute sm:top-8 md:top-9" style={{ left: `calc(${(index + 1) * 33.33}% - 16px)` }} />
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
