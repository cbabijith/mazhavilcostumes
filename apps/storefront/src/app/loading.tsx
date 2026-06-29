export default function Loading() {
  return (
    <div className="min-h-screen bg-silk animate-pulse">
      {/* Header skeleton */}
      <div className="h-16 bg-white/60 border-b border-[var(--border-silk)]" />
      {/* Hero skeleton */}
      <div className="max-w-[1440px] mx-auto px-4 sm:px-6 md:px-10 py-4 sm:py-6">
        <div className="w-full aspect-[21/10] md:aspect-[28/10] rounded-[2.5rem] bg-silk-dark/40" />
      </div>
      {/* Content skeleton */}
      <div className="max-w-[1440px] mx-auto px-4 sm:px-6 md:px-10 py-12 space-y-8">
        <div className="h-8 w-48 bg-silk-dark/30 rounded-full" />
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} className="aspect-[3/4] bg-silk-dark/30 rounded-2xl" />
          ))}
        </div>
      </div>
    </div>
  );
}
