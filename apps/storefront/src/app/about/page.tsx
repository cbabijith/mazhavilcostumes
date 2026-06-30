import Header from "@/components/home/Header";
import Footer from "@/components/home/Footer";
import { getParisBridalsStore } from "@/lib/actions/store";
import Image from "next/image";
import { CheckCircle2, Sparkles, Heart } from "lucide-react";

export default async function AboutPage() {
  const store = await getParisBridalsStore();
  if (!store) return null;

  const logoUrl = store.logo_url || "/logo_mazhavil.jpeg";

  return (
    <main className="min-h-screen bg-silk selection:bg-rosegold/20 selection:text-rosegold-dark">
      <Header store={store} />
      
      {/* Hero Section */}
      <section className="relative py-16 sm:py-20 flex items-center justify-center bg-white border-b border-[var(--border-silk)]">
        <div className="relative text-center px-6 max-w-4xl flex flex-col items-center">
          <div className="relative overflow-hidden rounded-full mb-8 border border-[var(--border-silk)]">
            <Image 
              src={logoUrl} 
              alt="Mazhavil Dance Costumes Logo" 
              width={160}
              height={160}
              unoptimized
              className="w-28 h-28 sm:w-36 sm:h-36 object-contain animate-fadeIn"
            />
          </div>
          <div className="section-eyebrow mb-4">About Us</div>
          <h1 className="text-4xl sm:text-5xl lg:text-6xl font-serif text-heading mb-6 tracking-tight">
            Mazhavil Dance Costumes
          </h1>
          <p className="text-base sm:text-lg font-light text-body leading-relaxed max-w-2xl mx-auto">
            With over 10 years of experience in the field, we proudly bring elegance, tradition, and creativity together through our premium costume collections. We are dedicated to providing beautifully designed costumes that make every performance special and memorable.
          </p>
        </div>
      </section>

      {/* Content Section */}
      <section className="py-16 sm:py-24 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto space-y-16">
          
          {/* Quality Standards Block */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-10 items-center">
            <div className="space-y-6">
              <h2 className="text-2xl sm:text-3xl font-serif text-heading">
                Hygiene & Safety <em className="text-rosegold italic">First</em>
              </h2>
              <p className="text-body font-light text-sm sm:text-base leading-relaxed">
                At our business, Hygiene & Safety come first because your comfort and confidence are our top priorities.
              </p>
              <ul className="space-y-3 pt-2">
                {[
                  "Clean and well-maintained",
                  "Neatly packed and ready to use",
                  "Managed with the highest standards of hygiene and safety",
                ].map((item, idx) => (
                  <li key={idx} className="flex items-start gap-3 text-sm text-body">
                    <CheckCircle2 className="text-rosegold shrink-0 mt-0.5" size={18} />
                    <span className="font-medium">{item}</span>
                  </li>
                ))}
              </ul>
            </div>
            <div className="bg-rosegold/5 rounded-[2.5rem] p-8 sm:p-10 border border-rosegold/10 text-center">
              <p className="text-xl sm:text-2xl font-serif text-rosegold italic leading-relaxed">
                "Our costumes are always sanitized, neatly pressed, and packed, ready for the stage."
              </p>
            </div>
          </div>

          {/* Categories Grid */}
          <div className="space-y-8">
            <div className="text-center">
              <div className="section-eyebrow justify-center">Our Offerings</div>
              <h2 className="text-3xl font-serif text-heading mt-2">Costumes for Every Stage</h2>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {[
                "Classical Dance",
                "Semi-Classical Dance",
                "Cinematic Dance",
                "Traditional Dance Programs",
                "Fancy Dress Costumes for Kids",
              ].map((category, idx) => (
                <div 
                  key={idx} 
                  className="bg-white rounded-3xl p-6 border border-[var(--border-silk)] shadow-sm hover:shadow-silk transition-all duration-300 flex items-center justify-center text-center group hover:-translate-y-1"
                >
                  <p className="text-sm font-sans font-bold text-heading group-hover:text-rosegold transition-colors">
                    {category}
                  </p>
                </div>
              ))}
            </div>
            <p className="text-center text-sm text-body font-light max-w-2xl mx-auto pt-2">
              We also provide a large variety of matching ornaments and accessories to give a complete and stunning look for every performance.
            </p>
          </div>

          {/* Why Choose Us */}
          <div className="bg-white rounded-[3rem] p-8 sm:p-12 shadow-silk border border-[var(--border-silk)] space-y-8">
            <div className="text-center">
              <div className="section-eyebrow justify-center">Why Choose Us</div>
              <h2 className="text-3xl font-serif text-heading mt-2">The Mazhavil Standard</h2>
            </div>
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-6 pt-2">
              {[
                "Quality Costumes",
                "Attractive Designs",
                "Affordable Rates",
                "Wide Variety of Collections",
                "Customer-Friendly Service",
              ].map((reason, idx) => (
                <div key={idx} className="flex flex-col items-center text-center space-y-2.5">
                  <div className="size-10 rounded-full bg-rosegold/10 flex items-center justify-center text-rosegold shrink-0">
                    <Sparkles size={16} />
                  </div>
                  <p className="text-[10px] sm:text-xs font-bold uppercase tracking-wide text-heading font-sans leading-tight">
                    {reason}
                  </p>
                </div>
              ))}
            </div>
          </div>

          {/* Invitation and Gratitude */}
          <div className="text-center max-w-2xl mx-auto space-y-6 pt-4">
            <p className="text-sm sm:text-base text-body leading-relaxed font-light">
              Whether it is a school function, stage performance, competition, cultural event, or festive celebration, we are here to help you shine with the perfect costume.
            </p>
            <div className="inline-flex size-10 rounded-full bg-rosegold/10 items-center justify-center text-rosegold">
              <Heart size={18} className="fill-rosegold" />
            </div>
            <p className="text-sm font-sans font-bold text-rosegold uppercase tracking-widest">
              Your support, trust, and encouragement mean everything to us.
            </p>
            <p className="text-xs sm:text-sm text-caption leading-relaxed font-light">
              We sincerely thank all our customers for being part of our journey and look forward to serving you with the best collections and service always.
            </p>
          </div>

        </div>
      </section>

      <Footer store={store} />
    </main>
  );
}
