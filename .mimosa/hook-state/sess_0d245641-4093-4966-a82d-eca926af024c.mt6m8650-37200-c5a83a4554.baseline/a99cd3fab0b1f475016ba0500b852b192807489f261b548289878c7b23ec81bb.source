/**
 * Homepage static data — reviews, editorial banners, trending, occasions, steps.
 *
 * @module data/homepage
 */

// ── Reviews ───────────────────────────────────────────────────────────
export interface Review {
  id: string;
  name: string;
  text: string;
  rating: number;
  occasion: string;
}

export const reviews: Review[] = [
  { id: "r1", name: "Aswathy Nair", text: "The Bharatanatyam costume was perfectly stitched, vibrant, and looked absolutely stunning on stage. The temple jewelry set included was in pristine condition.", rating: 5, occasion: "Arangetram, Trivandrum" },
  { id: "r2", name: "Devika Sajeev", text: "Rented Mohiniyattam costumes for our college group dance. Extremely clean, well-maintained, and the sizing fit perfectly. Will definitely rent again!", rating: 5, occasion: "Youth Festival, Kozhikode" },
  { id: "r3", name: "Rahul Krishnan", text: "Superb collection of folk and classical dance costumes. Easy booking over WhatsApp and prompt delivery. Highly recommended for school events.", rating: 5, occasion: "Annual Day Function, Kollam" },
];

// ── Editorial Banners ─────────────────────────────────────────────────
export interface EditorialBanner {
  id: string;
  title: string;
  subtitle: string;
  image: string;
  link: string;
}

export const editorialBanners: EditorialBanner[] = [
  {
    id: 'eb1',
    title: 'Bridal Collection',
    subtitle: 'Exquisite pieces handcrafted for your most memorable day. From traditional Kerala to contemporary designs.',
    image: 'https://images.unsplash.com/photo-1515377905703-c4788e51af15?w=800',
    link: '/collections?occasion=wedding',
  },
  {
    id: 'eb2',
    title: 'Festive Favourites',
    subtitle: 'Celebrate every festival in style with our curated collection of temple costumes and gold sets.',
    image: 'https://images.unsplash.com/photo-1602173574767-37ac01994b2a?w=800',
    link: '/collections?occasion=festival',
  },
];

// ── Trending Products ─────────────────────────────────────────────────
export interface TrendingProduct {
  id: string;
  name: string;
  category: string;
  pricePerDay: number;
  image: string;
  tag?: string;
}

export const trendingProducts: TrendingProduct[] = [
  {
    id: 't1',
    name: 'Kundan Bridal Set',
    category: 'Bridal Sets',
    pricePerDay: 2499,
    image: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600',
    tag: 'Trending',
  },
  {
    id: 't2',
    name: 'Temple Necklace Gold',
    category: 'Necklaces',
    pricePerDay: 1999,
    image: 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=600',
  },
  {
    id: 't3',
    name: 'Diamond Jhumka Pair',
    category: 'Earrings',
    pricePerDay: 1299,
    image: 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600',
    tag: 'Popular',
  },
  {
    id: 't4',
    name: 'Ruby & Gold Choker',
    category: 'Chokers',
    pricePerDay: 1799,
    image: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600',
  },
];

// ── Shop by Occasion ──────────────────────────────────────────────────
export interface Occasion {
  id: string;
  name: string;
  image: string;
  count: string;
}

export const occasions: Occasion[] = [
  {
    id: 'o1',
    name: 'Wedding',
    image: 'https://images.unsplash.com/photo-1515377905703-c4788e51af15?w=400',
    count: '120+',
  },
  {
    id: 'o2',
    name: 'Engagement',
    image: 'https://images.unsplash.com/photo-1602173574767-37ac01994b2a?w=400',
    count: '85+',
  },
  {
    id: 'o3',
    name: 'Reception',
    image: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=400',
    count: '70+',
  },
  {
    id: 'o4',
    name: 'Festival',
    image: 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=400',
    count: '95+',
  },
  {
    id: 'o5',
    name: 'Party',
    image: 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=400',
    count: '60+',
  },
];

// ── How It Works ──────────────────────────────────────────────────────
export interface HowItWorksStep {
  title: string;
  desc: string;
}

export const howItWorksSteps: HowItWorksStep[] = [
  { title: "Browse", desc: "Explore our collection of premium costumes." },
  { title: "Pick Dates", desc: "Select the date for your special event." },
  { title: "WhatsApp Order", desc: "Continue your order through WhatsApp with selected date and product" },
];

export const trustBadges = [
  { title: "Sanitized", icon: "✨" },
  { title: "Insured", icon: "🛡️" },
  { title: "Free Delivery", icon: "🚚" },
  { title: "Easy Return", icon: "↩️" },
];
