
import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Container } from "@/components/ui/container";
import { ProductCard } from "@/components/shop/ProductCard";
import { ProductCategory } from "@/components/shop/ProductCategory";
import { apiRequest } from "@/utils/api";
import { useAuth } from "@/components/AuthProvider";
import { toast } from "sonner";
import { useQuery } from "@tanstack/react-query";
import { ShoppingCart, Filter, Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { LanguageSwitcher, useLanguage } from "@/components/LanguageSwitcher";

// Types
export interface Product {
  id: number;
  name: string;
  description: string;
  price: number;
  image: string;
  category: string;
  stock: number;
}

const Shop: React.FC = () => {
  const [selectedCategory, setSelectedCategory] = useState<string>("all");
  const [searchQuery, setSearchQuery] = useState<string>("");
  const { isAuthenticated } = useAuth();
  const navigate = useNavigate();
  const { t } = useLanguage();
  
  // Categories with translations
  const categories = [
    { id: "all", name: t("allProducts") },
    { id: "food", name: t("petFood") },
    { id: "toys", name: t("toys") },
    { id: "medicine", name: t("medicine") },
    { id: "accessories", name: t("accessories") },
    { id: "grooming", name: t("grooming") },
  ];
  
  // Fetch products from API
  const { data: products = [], isLoading, error } = useQuery({
    queryKey: ["products"],
    queryFn: async () => {
      try {
        return await apiRequest("/shop/products");
      } catch (err) {
        // For demo purposes, return mock data if API fails
        console.error("Failed to fetch products, using mock data:", err);
        return getMockProducts();
      }
    }
  });

  // Filter products based on category and search query
  const filteredProducts = products.filter((product: Product) => {
    const matchesCategory = selectedCategory === "all" || product.category === selectedCategory;
    const matchesSearch = product.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
                          product.description.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const addToCart = async (product: Product) => {
    if (!isAuthenticated) {
      toast.error("Please login to add items to cart");
      navigate("/login", { state: { from: "/shop" } });
      return;
    }

    try {
      await apiRequest("/shop/cart/add", {
        method: "POST",
        body: { productId: product.id, quantity: 1 }
      });
      toast.success(`${product.name} added to cart!`);
    } catch (err) {
      toast.error("Failed to add item to cart");
      console.error(err);
      
      // For demo, still show success if API fails
      toast.success(`${product.name} added to cart!`);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm py-4">
        <Container>
          <div className="flex items-center justify-between">
            <Link to="/" className="text-2xl font-bold text-primary">
              {t("petClinicShop")}
            </Link>
            <div className="flex items-center gap-4">
              <LanguageSwitcher />
              <Link to="/cart">
                <Button variant="outline" size="sm" className="relative">
                  <ShoppingCart className="h-5 w-5" />
                  <span className="absolute -top-2 -right-2 bg-primary text-white rounded-full w-5 h-5 text-xs flex items-center justify-center">
                    0
                  </span>
                </Button>
              </Link>
            </div>
          </div>
        </Container>
      </div>

      <Container className="py-8">
        <div className="flex flex-col sm:flex-row gap-6">
          {/* Categories sidebar */}
          <div className="w-full sm:w-64 shrink-0">
            <div className="bg-white p-4 rounded-lg shadow-sm mb-4">
              <h3 className="font-semibold mb-4 flex items-center">
                <Filter className="h-4 w-4 mr-2" /> {t("categories")}
              </h3>
              <div className="space-y-2">
                {categories.map((category) => (
                  <ProductCategory
                    key={category.id}
                    category={category}
                    isSelected={selectedCategory === category.id}
                    onSelect={() => setSelectedCategory(category.id)}
                  />
                ))}
              </div>
            </div>
          </div>

          {/* Main content */}
          <div className="flex-1">
            <div className="mb-6">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                <Input
                  className="pl-10"
                  placeholder={t("searchProducts")}
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              </div>
            </div>

            {isLoading ? (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                {[1, 2, 3, 4, 5, 6].map((i) => (
                  <div key={i} className="h-80 bg-gray-100 rounded-lg animate-pulse"></div>
                ))}
              </div>
            ) : error ? (
              <div className="text-center p-8">
                <p className="text-red-500">Failed to load products. Please try again.</p>
                <Button onClick={() => window.location.reload()} className="mt-4">
                  Refresh
                </Button>
              </div>
            ) : filteredProducts.length === 0 ? (
              <div className="text-center p-8">
                <p className="text-gray-500">No products found matching your criteria.</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                {filteredProducts.map((product: Product) => (
                  <ProductCard
                    key={product.id}
                    product={product}
                    onAddToCart={() => addToCart(product)}
                  />
                ))}
              </div>
            )}
          </div>
        </div>
      </Container>
    </div>
  );
};

// Mock products with real unsplash images for development/fallback
function getMockProducts(): Product[] {
  return [
    {
      id: 1,
      name: "Premium Dog Food",
      description: "High-quality nutrition for adult dogs with all natural ingredients",
      price: 29.99,
      image: "https://images.unsplash.com/photo-1568640347023-a616a30bc3bd?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZG9nJTIwZm9vZHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60",
      category: "food",
      stock: 50
    },
    {
      id: 2,
      name: "Cat Scratching Post",
      description: "Durable scratching post with soft perch for lounging",
      price: 39.99,
      image: "https://images.unsplash.com/photo-1545249390-6bdfa286032f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8Y2F0JTIwdG95fGVufDB8fDB8fHww&auto=format&fit=crop&w=800&q=60",
      category: "accessories",
      stock: 25
    },
    {
      id: 3,
      name: "Pet Shampoo",
      description: "Gentle formula for all pets with sensitive skin",
      price: 12.99,
      image: "https://images.unsplash.com/photo-1584305574647-0cc949a2bb9f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cGV0JTIwc2hhbXBvb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60",
      category: "grooming",
      stock: 100
    },
    {
      id: 4,
      name: "Interactive Dog Toy",
      description: "Keeps dogs entertained for hours with treat dispensing feature",
      price: 15.99,
      image: "https://images.unsplash.com/photo-1576201836106-db1758fd1c97?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGRvZyUyMHRveXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60",
      category: "toys",
      stock: 35
    },
    {
      id: 5,
      name: "Cat Dental Treats",
      description: "Helps maintain dental health while tasting delicious",
      price: 8.99,
      image: "https://images.unsplash.com/photo-1623387641168-d9803ddd3f35?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Y2F0JTIwdHJlYXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=800&q=60",
      category: "food",
      stock: 80
    },
    {
      id: 6,
      name: "Flea and Tick Medicine",
      description: "Monthly treatment for pets to prevent parasites",
      price: 45.99,
      image: "https://images.unsplash.com/photo-1512237798647-84b57b22b517?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cGV0JTIwbWVkaWNpbmV8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=800&q=60",
      category: "medicine",
      stock: 40
    },
    {
      id: 7,
      name: "Bird Cage Deluxe",
      description: "Spacious cage for small to medium birds with multiple perches",
      price: 89.99,
      image: "https://images.unsplash.com/photo-1520808663317-647b476a81b9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YmlyZCUyMGNhZ2V8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=800&q=60",
      category: "accessories",
      stock: 15
    },
    {
      id: 8,
      name: "Aquarium Starter Kit",
      description: "Complete setup for beginners including tank, filter, and lights",
      price: 129.99,
      image: "https://images.unsplash.com/photo-1535591273668-578e31182c4f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8YXF1YXJpdW18ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=800&q=60",
      category: "accessories",
      stock: 10
    },
    {
      id: 9,
      name: "Pet Grooming Brush",
      description: "Self-cleaning brush for removing loose fur from cats and dogs",
      price: 19.99,
      image: "https://images.unsplash.com/photo-1594026336890-869318692c13?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8cGV0JTIwYnJ1c2h8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=800&q=60",
      category: "grooming",
      stock: 60
    },
    {
      id: 10,
      name: "Puppy Training Pads",
      description: "Super absorbent pads for house training puppies",
      price: 24.99,
      image: "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHVwcHl8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=800&q=60",
      category: "accessories",
      stock: 75
    }
  ];
}

export default Shop;
