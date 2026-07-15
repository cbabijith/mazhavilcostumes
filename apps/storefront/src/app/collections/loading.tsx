export default function Loading() {
  return (
    <div className="min-h-screen bg-silk animate-pulse">
      {/* Header skeleton */}
      <div className="h-16 bg-white/60 border-b border-[var(--border-silk)]" />
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
        {/* Heading skeleton */}
        <div className="mb-8">
          <div className="h-4 w-24 bg-silk-dark/30 rounded-full mb-4" />
          <div className="h-12 w-72 bg-silk-dark/30 rounded-full mb-3" />
          <div className="h-4 w-96 bg-silk-dark/20 rounded-full" />
        </div>
        {/* Grid skeleton */}
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3 sm:gap-5 lg:gap-6">
          {Array.from({ length: 12 }).map((_, i) => (
            <div key={i} className="aspect-[3/4] bg-silk-dark/30 rounded-2xl" />
          ))}
        </div>
      </div>
    </div>
  );
}
