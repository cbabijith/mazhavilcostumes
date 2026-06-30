"use client";

import { useState, useEffect } from "react";
import Header from "@/components/home/Header";
import Footer from "@/components/home/Footer";
import { getParisBridalsStore } from "@/lib/actions/store";
import { Mail, Phone, MapPin, Send, MessageCircle } from "lucide-react";
import { buildContactMessage, buildWhatsAppUrl } from "@/lib/whatsapp";
import { cn } from "@/lib/utils";

export default function ContactPage() {
  const [store, setStore] = useState<any>(null);
  const [mounted, setMounted] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    phone: "",
    message: "",
  });
  const [errors, setErrors] = useState<{ name?: string; phone?: string; message?: string }>({});

  useEffect(() => {
    async function loadStore() {
      const storeData = await getParisBridalsStore();
      setStore(storeData);
    }
    loadStore();
    setMounted(true);
  }, []);

  const validateForm = () => {
    const newErrors: { name?: string; phone?: string; message?: string } = {};
    if (!formData.name.trim()) {
      newErrors.name = "Name is required";
    }
    const cleanPhone = formData.phone.replace(/\D/g, "");
    if (!cleanPhone) {
      newErrors.phone = "Phone number is required";
    } else if (!/^[6-9]\d{9}$/.test(cleanPhone)) {
      newErrors.phone = "Enter a valid 10-digit Indian mobile number";
    }
    if (!formData.message.trim()) {
      newErrors.message = "Message is required";
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateForm()) return;
    const cleanPhone = formData.phone.replace(/\D/g, "");
    const message = buildContactMessage(formData.name, cleanPhone, formData.message);
    window.open(buildWhatsAppUrl(message), "_blank");
  };

  const handleInputChange = (field: string, value: string) => {
    setFormData({ ...formData, [field]: value });
    if (errors[field as keyof typeof errors]) {
      setErrors({ ...errors, [field]: undefined });
    }
  };

  if (!mounted) return null;

  return (
    <main className="min-h-screen bg-white pb-20 lg:pb-0">
      <Header store={store} />

      <section className="py-8 sm:py-12 md:py-16 px-4 sm:px-6 md:px-12">
        <div className="max-w-[1000px] mx-auto">
          {/* Header */}
          <div className="text-center mb-8 sm:mb-10">
            <span className="text-[10px] uppercase tracking-[0.2em] font-bold text-rosegold block mb-2">
              Get in Touch
            </span>
            <h1 className="text-2xl sm:text-3xl md:text-4xl font-bold text-heading mb-3">
              Contact Us
            </h1>
            <p className="text-sm text-body max-w-lg mx-auto">
              Have questions? We'd love to hear from you. Send us a message and we'll respond as soon as possible.
            </p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 sm:gap-8">
            {/* Form */}
            <div className="border border-[#EAEAEA] rounded-2xl p-5 sm:p-6">
              <h2 className="text-base font-semibold text-heading mb-5">Send a Message</h2>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="text-xs font-medium text-body block mb-1.5">Name *</label>
                  <input
                    type="text"
                    value={formData.name}
                    onChange={(e) => handleInputChange("name", e.target.value)}
                    className={cn(
                      "w-full px-3 py-2.5 bg-white border rounded-lg text-sm focus:outline-none transition-colors placeholder:text-body/50",
                      errors.name ? "border-red-400 focus:border-red-500" : "border-[#EAEAEA] focus:border-rosegold"
                    )}
                    placeholder="Your name"
                  />
                  {errors.name && <p className="text-xs text-red-500 mt-1">{errors.name}</p>}
                </div>

                <div>
                  <label className="text-xs font-medium text-body block mb-1.5">Phone Number *</label>
                  <div className="flex gap-2">
                    <div className="flex items-center justify-center px-3 bg-gray-50 border border-[#EAEAEA] rounded-lg text-sm text-heading font-medium shrink-0">
                      +91
                    </div>
                    <input
                      type="tel"
                      value={formData.phone}
                      onChange={(e) => handleInputChange("phone", e.target.value.replace(/\D/g, "").slice(0, 10))}
                      className={cn(
                        "flex-1 px-3 py-2.5 bg-white border rounded-lg text-sm focus:outline-none transition-colors placeholder:text-body/50",
                        errors.phone ? "border-red-400 focus:border-red-500" : "border-[#EAEAEA] focus:border-rosegold"
                      )}
                      placeholder="10-digit mobile number"
                      inputMode="numeric"
                      maxLength={10}
                    />
                  </div>
                  {errors.phone && <p className="text-xs text-red-500 mt-1">{errors.phone}</p>}
                </div>

                <div>
                  <label className="text-xs font-medium text-body block mb-1.5">Message *</label>
                  <textarea
                    value={formData.message}
                    onChange={(e) => handleInputChange("message", e.target.value)}
                    rows={4}
                    className={cn(
                      "w-full px-3 py-2.5 bg-white border rounded-lg text-sm focus:outline-none transition-colors placeholder:text-body/50 resize-none",
                      errors.message ? "border-red-400 focus:border-red-500" : "border-[#EAEAEA] focus:border-rosegold"
                    )}
                    placeholder="How can we help you?"
                  />
                  {errors.message && <p className="text-xs text-red-500 mt-1">{errors.message}</p>}
                </div>

                <button
                  type="submit"
                  className="w-full py-3.5 rounded-full bg-rosegold text-white text-sm font-semibold hover:bg-rosegold-dark transition-colors flex items-center justify-center gap-2"
                >
                  <Send size={16} strokeWidth={1.8} />
                  Send via WhatsApp
                </button>
              </form>
            </div>

            {/* Contact Info */}
            <div className="space-y-4">
              <div className="border border-[#EAEAEA] rounded-2xl p-5 sm:p-6">
                <h2 className="text-base font-semibold text-heading mb-5">Contact Information</h2>

                <div className="space-y-5">
                  <div className="flex items-start gap-3">
                    <div className="w-9 h-9 bg-rosegold/5 text-rosegold rounded-lg flex items-center justify-center shrink-0">
                      <Phone size={16} strokeWidth={1.8} />
                    </div>
                    <div className="min-w-0">
                      <p className="text-xs text-body mb-1">Mob / Whatsapp</p>
                      <div className="flex flex-col gap-0.5">
                        <a href="tel:9446961765" className="text-sm font-medium text-heading hover:text-rosegold transition-colors">
                          +91 94469 61765
                        </a>
                        <a href="tel:9447961765" className="text-sm font-medium text-heading hover:text-rosegold transition-colors">
                          +91 94479 61765
                        </a>
                      </div>
                    </div>
                  </div>

                  <div className="flex items-start gap-3">
                    <div className="w-9 h-9 bg-rosegold/5 text-rosegold rounded-lg flex items-center justify-center shrink-0">
                      <Mail size={16} strokeWidth={1.8} />
                    </div>
                    <div className="min-w-0">
                      <p className="text-xs text-body mb-1">Email</p>
                      <a href="mailto:mazhavildancecostumes@gmail.com" className="text-sm font-medium text-heading hover:text-rosegold transition-colors break-all">
                        mazhavildancecostumes@gmail.com
                      </a>
                    </div>
                  </div>

                  <div className="flex items-start gap-3">
                    <div className="w-9 h-9 bg-rosegold/5 text-rosegold rounded-lg flex items-center justify-center shrink-0">
                      <MapPin size={16} strokeWidth={1.8} />
                    </div>
                    <div className="min-w-0">
                      <p className="text-xs text-body mb-1">Address</p>
                      <a
                        href="https://www.google.com/maps/search/?api=1&query=8.481222,76.965056"
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-sm text-heading leading-relaxed hover:text-rosegold transition-colors"
                      >
                        Karamana Main Road, near QRS, Karamana, Thiruvananthapuram, Kerala 695002
                      </a>
                    </div>
                  </div>
                </div>
              </div>

              {/* Quick Response */}
              <div className="bg-rosegold/5 border border-rosegold/10 rounded-2xl p-5 sm:p-6 text-center">
                <div className="w-10 h-10 bg-rosegold/10 text-rosegold rounded-full flex items-center justify-center mx-auto mb-3">
                  <MessageCircle size={18} strokeWidth={1.8} />
                </div>
                <h3 className="text-sm font-semibold text-heading mb-2">Quick Response</h3>
                <p className="text-xs text-body mb-4 max-w-xs mx-auto">
                  For fastest response, reach out to us directly on WhatsApp.
                </p>
                <a
                  href={buildWhatsAppUrl("Hi, I have a question.")}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center justify-center px-6 py-3 rounded-full bg-rosegold text-white text-sm font-semibold hover:bg-rosegold-dark transition-colors"
                >
                  Chat on WhatsApp
                </a>
              </div>
            </div>
          </div>
        </div>
      </section>

      <Footer store={store} />
    </main>
  );
}
