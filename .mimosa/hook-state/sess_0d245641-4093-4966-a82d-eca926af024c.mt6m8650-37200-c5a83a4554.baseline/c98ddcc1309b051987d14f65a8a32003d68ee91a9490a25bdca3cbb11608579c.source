import { ShieldCheck, Truck, Sparkles, Headphones } from "lucide-react";

const badges = [
  {
    icon: ShieldCheck,
    title: "Certified Quality",
    description: "Verified by experts",
  },
  {
    icon: Truck,
    title: "Safe Delivery",
    description: "Secure & insured",
  },
  {
    icon: Sparkles,
    title: "Pristine Condition",
    description: "Cleaned & sanitized",
  },
  {
    icon: Headphones,
    title: "Trusted Support",
    description: "We're here to help",
  },
];

export default function TrustBadges() {
  return (
    <section className="bg-white py-6 px-3 sm:px-6">
      <div className="max-w-[1200px] mx-auto">
        <div className="grid grid-cols-4">
            {badges.map((badge, index) => (
              <div
                key={index}
                className={`flex min-w-0 flex-col items-start px-2 py-4 sm:p-5 ${
                  index !== badges.length - 1 ? "border-r border-[#EAEAEA]" : ""
                }`}
              >
                <badge.icon
                  className="text-[#EC4899] mb-2 h-[18px] w-[18px] sm:mb-3 sm:h-7 sm:w-7"
                  strokeWidth={1.9}
                />
                <h3 className="mb-1 max-w-full truncate text-[10px] font-semibold leading-tight text-gray-900 sm:text-[16px]">
                  {badge.title}
                </h3>
                <p className="max-w-full truncate text-[9px] font-medium leading-tight text-[#6B7280] sm:text-[12px]">
                  {badge.description}
                </p>
              </div>
            ))}
          </div>
      </div>
    </section>
  );
}
