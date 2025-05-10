# Dotidot – Ruby Back-end Developer Task

As a Dotidot user, I have the option to use the **Scraper** to expand my data with new fields.  
The goal of the task is to create a standalone Rails application with a simple interface for the scraper.  
It should receive a URL address and a list of fields to extract from the webpage on the given URL in the request.

---

## Task #1 – Basic Scraper Functionality

Use simple CSS selectors to extract data.

**Request:**

```http
GET /data
```

**JSON body:**

```json
{
  "url": "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm",
  "fields": { 
    "price": ".price-box__price",
    "rating_count": ".ratingCount", 
    "rating_value": ".ratingValue" 
  }
}
```

**Expected response:**

```json
{
  "price": "18290,-",
  "rating_value": "4,9",
  "rating_count": "7 hodnocení"
}
```

---

## Task #2 – Meta Information Extraction

Add support for meta tags. Include `"meta"` in the fields array, listing the `name` attributes of desired meta tags.

**Request:**

```json
{
  "url": "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm",
  "fields": { 
    "meta": ["keywords", "twitter:image"]
  }
}
```

**Expected response:**

```json
{
  "meta": {
    "keywords": "Parní pračka AEG 7000 ProSteam® LFR73964CC na www.alza.cz. ✅ Bezpečný nákup. ✅ Veškeré informace o produktu. ✅ Vhodné příslušenství. ✅ Hodnocení a recenze AEG...",
    "twitter:image": "https://image.alza.cz/products/AEGPR065/AEGPR065.jpg?width=360&height=360"
  }
}
```

---

## Task #3 – Optimization and Caching

Implement caching for individual downloads.  
The same URL may be requested multiple times with different fields.  
Your solution should include tests.

📌 **Deliverable**: Push your result to GitHub and send us the repository link.

---

## Task #4 – Interview Preparation

Prepare to discuss:
- How this application could evolve over time
- Weaknesses in the current approach
- Opportunities for acceleration and parallelism

---

**Thank you for the effort and time you put into this task. We appreciate it a lot!**
