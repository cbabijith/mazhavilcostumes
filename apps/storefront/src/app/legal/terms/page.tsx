import Header from "@/components/home/Header";
import Footer from "@/components/home/Footer";
import { getParisBridalsStore } from "@/lib/actions/store";

export default async function TermsPage() {
  const store = await getParisBridalsStore();
  if (!store) return null;

  return (
    <main className="min-h-screen bg-silk">
      <Header store={store} />
      <section className="py-20 px-4 sm:px-8 max-w-4xl mx-auto">
        <h1 className="text-4xl font-serif mb-10 text-heading">Terms of Service</h1>
        <div className="prose prose-stone max-w-none space-y-6 text-body">
          <p>Effective Date: April 20, 2026</p>
          <h2 className="text-xl font-bold text-heading">1. Rental Agreement</h2>
          <p>By renting from Paris Bridals, you agree to return all jewelry, sets, accessories, and components in the same pristine condition as received. Rental periods are strictly enforced.</p>
          <h2 className="text-xl font-bold text-heading">2. Security Deposit</h2>
          <p>A security deposit is required for all jewelry rentals. This will be fully refunded within 3-5 business days after the items are returned, inspected, and verified to have no missing stones, bent prongs, or structural damages.</p>
          <h2 className="text-xl font-bold text-heading">3. Damage and Loss</h2>
          <p>The customer is responsible for any damage beyond normal wear and tear (e.g., missing gemstones, severe scratches, broken clasps, or structural deformation). In case of irreparable damage, loss, or theft of any part of a set, the full replacement value of the piece will be charged.</p>
        </div>
      </section>
      <Footer store={store} />
    </main>
  );
}
