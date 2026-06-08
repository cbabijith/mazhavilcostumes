import Header from "@/components/home/Header";
import Footer from "@/components/home/Footer";
import { getParisBridalsStore } from "@/lib/actions/store";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";

export default async function FAQsPage() {
  const store = await getParisBridalsStore();
  if (!store) return null;

  const faqCategories = [
    {
      name: "Rental Process",
      items: [
        {
          q: "How does the rental process work?",
          a: "Select your costumes, choose your dates, and pay the rental fee + security deposit. We deliver (or you pick up), you shine at your event, and then return the piece within the agreed time.",
        },
        {
          q: "How far in advance should I book?",
          a: "For season time book a month in advance,For normal time visist at your convenience",
        },
      ],
    },
    {
      name: "Care & Sanitization",
      items: [
        {
          q: "Is the costumes sanitized?",
          a: "Absolutely. We take great care in maintaining the cleanliness and quality of our dance costumes. Every costume is thoroughly washed, inspected, and professionally prepared before and after each rental to ensure it is fresh, clean, and ready for use.",
        },
        {
          q: "What if I accidentally damage a piece?",
          a: `We understand that accidents can happen, and normal wear and tear is expected. However, any major damage, permanent stains, missing accessories, or loss of costumes will be evaluated upon return, and additional charges may apply for repair or replacement.

We kindly request that customers take extra care while using the costumes and avoid applying Alta (Altha) or any other materials that may cause permanent staining or damage to the fabric.`,
        },
      ],
    },
  ];

  return (
    <main className="min-h-screen bg-silk">
      <Header store={store} />

      <section className="py-20 sm:py-32 px-4">
        <div className="max-w-3xl mx-auto text-center mb-16">
          <div className="section-eyebrow justify-center">Questions & Answers</div>
          <h1 className="text-5xl font-serif text-heading mb-6">Frequently Asked</h1>
          <p className="text-body font-light">
            Everything you need to know about renting our treasures.
          </p>
        </div>

        <div className="max-w-3xl mx-auto space-y-12 pb-20">
          {faqCategories.map((cat) => (
            <div key={cat.name} className="space-y-6">
              <h2 className="text-xs uppercase tracking-[0.3em] font-bold text-rosegold border-b border-[var(--border-silk)] pb-4">
                {cat.name}
              </h2>
              <Accordion type="single" collapsible className="w-full space-y-4">
                {cat.items.map((item, idx) => (
                  <AccordionItem
                    key={idx}
                    value={`${cat.name}-${idx}`}
                    className="bg-white rounded-3xl border border-[var(--border-silk)] px-6 shadow-sm overflow-hidden"
                  >
                    <AccordionTrigger className="hover:no-underline hover:text-rosegold text-left font-serif text-lg py-6">
                      {item.q}
                    </AccordionTrigger>
                    <AccordionContent className="text-body leading-relaxed pb-6 opacity-80 whitespace-pre-line">
                      {item.a}
                    </AccordionContent>
                  </AccordionItem>
                ))}
              </Accordion>
            </div>
          ))}
        </div>
      </section>

      <Footer store={store} />
    </main>
  );
}
