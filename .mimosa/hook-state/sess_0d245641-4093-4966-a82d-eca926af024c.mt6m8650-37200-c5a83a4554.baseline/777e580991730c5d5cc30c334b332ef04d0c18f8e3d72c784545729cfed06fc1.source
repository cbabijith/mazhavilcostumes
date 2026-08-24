export default function Loading() {
  return (
    <div className="min-h-screen bg-silk animate-pulse">
      {/* Header skeleton */}
      <div className="h-16 bg-white/60 border-b border-[var(--border-silk)]" />
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
        <div className="h-8 w-32 bg-silk-dark/30 rounded-full mb-8" />
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="aspect-square bg-silk-dark/30 rounded-2xl" />
          ))}
        </div>
      </div>
    </div>
  );
}
