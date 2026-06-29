import { Card } from "@/components/ui/card";

// Custom colored icons matching the image design - 26px size
function CertifiedQualityIcon() {
  return (
    <svg width="26" height="26" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M24 4L8 10V22C8 32.4 14.8 41.8 24 44C33.2 41.8 40 32.4 40 22V10L24 4Z" fill="#22C55E"/>
      <path d="M16 24L22 30L32 18" stroke="white" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

function SafeDeliveryIcon() {
  return (
    <svg width="26" height="26" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M8 18H32V36H8V18Z" fill="#EF4444"/>
      <path d="M32 24H40C41.1 24 42 24.9 42 26V36H32V24Z" fill="#EF4444"/>
      <circle cx="14" cy="36" r="4" fill="white"/>
      <circle cx="36" cy="36" r="4" fill="white"/>
      <path d="M8 18L4 12H28L32 18" stroke="#EF4444" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

function PristineConditionIcon() {
  return (
    <svg width="26" height="26" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M24 4L28 16L40 20L30 28L32 40L24 34L16 40L18 28L8 20L20 16L24 4Z" fill="#EC4899"/>
      <circle cx="12" cy="12" r="2" fill="#EC4899"/>
      <circle cx="38" cy="14" r="2" fill="#EC4899"/>
      <circle cx="10" cy="36" r="1.5" fill="#EC4899"/>
      <circle cx="40" cy="32" r="1.5" fill="#EC4899"/>
    </svg>
  );
}

function TrustedServiceIcon() {
  return (
    <svg width="26" height="26" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M24 4C14 4 6 12 6 22V28C6 30.2 7.8 32 10 32H14V24C14 22.9 14.9 22 16 22H32C33.1 22 34 22.9 34 24V32H38C40.2 32 42 30.2 42 28V22C42 12 34 4 24 4Z" fill="#EF4444"/>
      <rect x="14" y="24" width="20" height="20" rx="2" fill="#EF4444"/>
      <path d="M24 32V36M24 36L21 33M24 36L27 33" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

const badges = [
  {
    icon: CertifiedQualityIcon,
    title: "Certified Quality",
    description: "Each piece is hand-selected and verified by experts",
  },
  {
    icon: SafeDeliveryIcon,
    title: "Safe Delivery",
    description: "Insured and tracked shipping to your doorstep",
  },
  {
    icon: PristineConditionIcon,
    title: "Pristine Condition",
    description: "Professionally cleaned and sanitized after every use",
  },
  {
    icon: TrustedServiceIcon,
    title: "Trusted Service",
    description: "Over 500+ dancers adorned across the region",
  },
];

export default function TrustBadges() {
  return (
    <section className="bg-white py-6 px-4 sm:px-6">
      <div className="max-w-[1200px] mx-auto">
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 sm:gap-4">
          {badges.map((badge, index) => (
            <Card
              key={index}
              className="flex flex-col items-center justify-center text-center p-3 bg-white border border-[#EAEAEA] rounded-[18px] shadow-sm hover:shadow-md transition-shadow duration-300 h-full"
            >
              <div className="mb-2">
                <badge.icon />
              </div>
              <h3 className="text-[16px] font-semibold text-gray-900 mb-1">
                {badge.title}
              </h3>
              <p className="text-[12px] font-medium text-[#6B7280] whitespace-nowrap overflow-hidden text-ellipsis max-w-full">
                {badge.description}
              </p>
            </Card>
          ))}
        </div>
      </div>
    </section>
  );
}
