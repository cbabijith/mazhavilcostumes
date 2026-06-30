import Link from "next/link";

export default function FinalCTA() {
  return (
    <section className="bg-white py-10 sm:py-14 md:py-20 px-4 sm:px-6 md:px-12">
      <div className="max-w-[800px] mx-auto text-center">
        <span className="text-[10px] sm:text-xs uppercase tracking-[0.2em] font-bold text-rosegold">
          Your Performance Awaits
        </span>
        <h2 className="text-2xl sm:text-3xl md:text-4xl font-bold text-heading mt-3 sm:mt-4 leading-tight">
          Dress for the Spotlight
        </h2>
        <p className="text-sm sm:text-base text-body mt-3 sm:mt-4 leading-relaxed max-w-xl mx-auto">
          Rent Kerala's most exquisite collection of classical, folk, and cinematic dance costumes. Crafted with premium fabrics to bring elegance, color, and grace to every movement.
        </p>

        <Link
          href="/collections"
          className="inline-flex items-center justify-center mt-6 sm:mt-8 px-6 py-3 sm:px-8 sm:py-3.5 rounded-full bg-rosegold text-white text-xs sm:text-sm font-semibold hover:bg-rosegold-dark transition-colors duration-300"
        >
          Explore Collections
        </Link>
      </div>
    </section>
  );
}
