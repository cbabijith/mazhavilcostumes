import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  turbopack: {
    root: path.resolve(__dirname, '../..'),
  },
  images: {
    unoptimized: true,
    formats: ['image/webp'],
    minimumCacheTTL: 86400,
    deviceSizes: [640, 750, 1080, 1920],
    imageSizes: [32, 64, 128, 256],
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'pub-0034dd36936640008811a977b5359f89.r2.dev',
      },
      {
        protocol: 'https',
        hostname: '*.r2.dev',
      },
    ],
  },
};

export default nextConfig;
