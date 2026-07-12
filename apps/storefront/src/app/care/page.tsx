import Header from '@/components/home/Header';
import Footer from '@/components/home/Footer';
import { getParisBridalsStore } from '@/lib/actions/store';
import { Button } from '@/components/ui/button';
import { Droplets, Sun, Sparkles, Shield, HelpCircle } from 'lucide-react';
import { buildWhatsAppUrl } from '@/lib/whatsapp';

export default async function CarePage() {
  const store = await getParisBridalsStore();
  if (!store) return null;

  const whatsappMessage = 'Hi, I have a question about jewelry and accessories care.';
  const whatsappUrl = buildWhatsAppUrl(whatsappMessage);

  return (
    <main className="min-h-screen bg-silk">
      <Header store={store} />

      <section className="py-12 sm:py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-16">
            <div className="section-eyebrow justify-center">Preservation</div>
            <h1 className="text-4xl sm:text-5xl font-serif text-heading mb-4">
              Jewelry Care Instructions
            </h1>
            <p className="text-body font-light max-w-2xl mx-auto">
              Keep your rented bridal jewelry and accessories looking pristine with these simple
              care guidelines.
            </p>
          </div>

          <div className="space-y-8 mb-16">
            <div className="bg-white rounded-3xl p-8 shadow-sm border border-[var(--border-silk)]">
              <div className="flex items-start gap-4 mb-4">
                <div className="w-12 h-12 bg-rosegold/5 text-rosegold rounded-2xl flex items-center justify-center flex-shrink-0">
                  <Droplets size={24} strokeWidth={1.5} />
                </div>
                <div>
                  <h2 className="font-serif text-heading text-xl mb-2">Avoid Water & Moisture</h2>
                  <p className="text-body text-sm leading-relaxed">
                    Remove jewelry and accessories before showering, swimming, or washing hands.
                    Moisture can cause tarnishing, discolouration, and weaken gemstone adhesives or
                    settings. If any piece gets wet, pat dry immediately with a clean, soft cloth.
                  </p>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-3xl p-8 shadow-sm border border-[var(--border-silk)]">
              <div className="flex items-start gap-4 mb-4">
                <div className="w-12 h-12 bg-rosegold/5 text-rosegold rounded-2xl flex items-center justify-center flex-shrink-0">
                  <Sun size={24} strokeWidth={1.5} />
                </div>
                <div>
                  <h2 className="font-serif text-heading text-xl mb-2">Avoid Chemicals</h2>
                  <p className="text-body text-sm leading-relaxed mb-3">
                    Chemicals can severely damage delicate metal platings and precious gemstones.
                    Avoid contact with:
                  </p>
                  <ul className="text-body text-sm space-y-2">
                    <li className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 bg-rosegold rounded-full"></span>
                      Perfumes, body sprays, and colognes
                    </li>
                    <li className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 bg-rosegold rounded-full"></span>
                      Hairsprays, styling gels, and setting sprays
                    </li>
                    <li className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 bg-rosegold rounded-full"></span>
                      Lotions, makeup, moisturizers, and body oils
                    </li>
                    <li className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 bg-rosegold rounded-full"></span>
                      Sanitizers, soaps, and household bleach
                    </li>
                  </ul>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-3xl p-8 shadow-sm border border-[var(--border-silk)]">
              <div className="flex items-start gap-4 mb-4">
                <div className="w-12 h-12 bg-rosegold/5 text-rosegold rounded-2xl flex items-center justify-center flex-shrink-0">
                  <Sparkles size={24} strokeWidth={1.5} />
                </div>
                <div>
                  <h2 className="font-serif text-heading text-xl mb-2">Cleaning & Maintenance</h2>
                  <p className="text-body text-sm leading-relaxed mb-3">
                    For light cleaning during your rental period:
                  </p>
                  <ul className="text-body text-sm space-y-2">
                    <li className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 bg-rosegold rounded-full"></span>
                      Gently wipe pieces with a soft, lint-free polishing cloth
                    </li>
                    <li className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 bg-rosegold rounded-full"></span>
                      Never use abrasive materials, paper towels, or tissues (they can scratch the
                      plating)
                    </li>
                    <li className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 bg-rosegold rounded-full"></span>
                      Do not use liquid jewelry cleaners or harsh chemicals
                    </li>
                    <li className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 bg-rosegold rounded-full"></span>
                      If a gemstone or hook loosens, do not attempt to glue it yourself; contact us
                      immediately
                    </li>
                  </ul>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-3xl p-8 shadow-sm border border-[var(--border-silk)]">
              <div className="flex items-start gap-4 mb-4">
                <div className="w-12 h-12 bg-rosegold/5 text-rosegold rounded-2xl flex items-center justify-center flex-shrink-0">
                  <Shield size={24} strokeWidth={1.5} />
                </div>
                <div>
                  <h2 className="font-serif text-heading text-xl mb-2">Safe Storage</h2>
                  <p className="text-body text-sm leading-relaxed mb-3">
                    When not wearing, store jewelry safely:
                  </p>
                  <ul className="text-body text-sm space-y-2">
                    <li className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 bg-rosegold rounded-full"></span>
                      Always keep pieces inside the provided padded boxes or pouches
                    </li>
                    <li className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 bg-rosegold rounded-full"></span>
                      Store necklaces, earrings, and bangles separately to prevent tangling or
                      scratching
                    </li>
                    <li className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 bg-rosegold rounded-full"></span>
                      Keep in a dry, cool environment away from direct sunlight and heat sources
                    </li>
                  </ul>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-3xl p-8 shadow-sm border border-[var(--border-silk)]">
              <div className="flex items-start gap-4 mb-4">
                <div className="w-12 h-12 bg-rosegold/5 text-rosegold rounded-2xl flex items-center justify-center flex-shrink-0">
                  <HelpCircle size={24} strokeWidth={1.5} />
                </div>
                <div>
                  <h2 className="font-serif text-heading text-xl mb-2">
                    During Your Wedding & Events
                  </h2>
                  <ul className="text-body text-sm space-y-2">
                    <li className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 bg-rosegold rounded-full"></span>
                      Put jewelry on last, after your bridal makeup, hairspray, and perfume have
                      completely dried
                    </li>
                    <li className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 bg-rosegold rounded-full"></span>
                      Remove jewelry first before changing outfits or clothes to avoid snagging
                      delicate fabrics
                    </li>
                    <li className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 bg-rosegold rounded-full"></span>
                      Double check clasps, safety latches, and earring backings to ensure they are
                      securely fastened
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>

          <div className="bg-rosegold/5 rounded-3xl p-8 text-center">
            <h2 className="font-serif text-heading text-xl mb-3">Need Care Advice?</h2>
            <p className="text-body text-sm mb-6 max-w-md mx-auto">
              Have questions about handling, cleaning, or storing your rented bridal jewelry?
              Contact our team on WhatsApp.
            </p>
            <a
              href={whatsappUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-block"
            >
              <Button className="shimmer-btn px-8 py-4 rounded-full text-xs uppercase tracking-widest font-bold">
                Ask on WhatsApp
              </Button>
            </a>
          </div>
        </div>
      </section>

      <Footer store={store} />
    </main>
  );
}
