---
layout: page
title: Services
permalink: /services/
---

<style>
.services-overview {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
}

.services-overview h1 {
  text-align: center;
  color: #435159;
  font-size: 42px;
  margin-bottom: 20px;
}

.services-overview .intro {
  text-align: center;
  color: #435159;
  font-size: 20px;
  max-width: 800px;
  margin: 0 auto 60px;
  line-height: 1.6;
}

.services-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 30px;
  margin-top: 40px;
}

.service-card {
  background: #fff;
  border: 2px solid #eef0f2;
  border-radius: 8px;
  padding: 30px;
  text-align: center;
  transition: all 0.3s ease;
}

.service-card:hover {
  border-color: #fab80a;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  transform: translateY(-5px);
}

.service-card h2 {
  color: #435159;
  font-size: 24px;
  margin-bottom: 15px;
}

.service-card p {
  color: #435159;
  font-size: 18px;
  line-height: 1.6;
  margin-bottom: 20px;
}

.service-card .price {
  color: #fab80a;
  font-size: 28px;
  font-weight: bold;
  margin-bottom: 20px;
}

.service-card .learn-more {
  display: inline-block;
  background: #fab80a;
  color: #435159;
  padding: 12px 30px;
  text-decoration: none;
  border-radius: 4px;
  font-weight: bold;
  transition: all 0.3s ease;
}

.service-card .learn-more:hover {
  background: #e95262;
  color: #fff3e2;
}

@media (max-width: 768px) {
  .services-overview h1 {
    font-size: 32px;
  }

  .services-overview .intro {
    font-size: 18px;
  }

  .services-grid {
    grid-template-columns: 1fr;
  }
}
</style>

<div class="services-overview">
  <h1>Purchase Our Brand Marketing Services</h1>
  <p class="intro">Extraordinary brand marketing for food & beverage start-ups at an accessible price.</p>

  <div class="services-grid">
    <div class="service-card">
      <h2>Brand Marketing Diagnostic</h2>
      <p>A framework and coaching session to get clear about your Brand Equity and why you'll win in-market</p>
      <div class="price">$499</div>
      <a href="{{ '/services/brand-diagnostic/' | relative_url }}" class="learn-more">Learn More</a>
    </div>

    <div class="service-card">
      <h2>Marketing Strategy Creation</h2>
      <p>A three month strategic plan of your Marketing Objectives and Marketing Tactics</p>
      <div class="price">$4,999</div>
      <a href="{{ '/services/marketing-strategy/' | relative_url }}" class="learn-more">Learn More</a>
    </div>

    <div class="service-card">
      <h2>Brand DNA Workshop</h2>
      <p>A facilitated workshop to define your brand's purpose, values, and personality</p>
      <div class="price">$2,999</div>
      <a href="{{ '/services/brand-workshop/' | relative_url }}" class="learn-more">Learn More</a>
    </div>

    <div class="service-card">
      <h2>Brand DNA Workbook</h2>
      <p>A self-guided workbook to discover and document your brand's DNA</p>
      <div class="price">$99</div>
      <a href="{{ '/services/brand-workbook/' | relative_url }}" class="learn-more">Learn More</a>
    </div>

    <div class="service-card">
      <h2>Brand Primer Template</h2>
      <p>A comprehensive template to create your brand guidelines and positioning</p>
      <div class="price">$99</div>
      <a href="{{ '/services/brand-primer/' | relative_url }}" class="learn-more">Learn More</a>
    </div>
  </div>
</div>
