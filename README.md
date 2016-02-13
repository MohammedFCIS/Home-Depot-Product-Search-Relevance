# Home Depot Product Search Relevance
## The problem to Solve
**Home Depot Product Search Relevance** is Kaggle competition targets to improve **Home Depot** customers' shopping experience by developing a model that can accurately predict the relevance of search results.

Search relevancy is an implicit measure **Home Depot** uses to gauge how quickly they can get customers to the right products. Currently, human raters evaluate the impact of potential changes to their search algorithms, which is a slow and subjective process. By removing or minimizing human input in search relevance evaluation, the target is to predict the relevance for each pair listed in the test set. Given that the test set contains both seen and unseen search terms.
## The Data
This data set contains a number of products and real customer search terms from Home Depot's website. The challenge is to predict a relevance score for the provided combinations of search terms and products.

The relevance is a number between 1 (not relevant) to 3 (highly relevant). For example, a search for "AA battery" would be considered highly relevant to a pack of size AA batteries (relevance = 3), mildly relevant to a cordless drill battery (relevance = 2), and not relevant to a snow shovel (relevance = 1).

###File descriptions
- ***train.csv*** --> the training set, contains products, searches, and relevance scores.
- ***test.csv*** --> the test set, data will be used to submitting to the Kaggle competition. Since I would not expect to finish the Capstone in time for the Kaggle competition deadline, we may or may not work with this file.
- ***product_descriptions.csv*** contains a text description of each product. I may join this table to the training or test set via the product_uid.
- ***attributes.csv***  provides extended information about a subset of the products (typically representing detailed technical specifications). Not every product will have attributes.
- ***sample_submission.csv*** a file showing the correct submission format.
- ***relevance_instructions.docx*** the instructions provided to human raters.

### Data fields
- ***id*** a unique Id field which represents a (search_term, product_uid) pair
- ***product_uid*** an id for the products
- ***product_title*** the product title
- ***product_description*** the text description of the product (may contain HTML content)
- ***search_term*** the search query
- ***relevance*** the average of the relevance ratings for a given id
- name an attribute name
- ***value*** the attribute's value
### Data Source
[Home Depot Products Dataset](https://www.kaggle.com/c/home-depot-product-search-relevance/data?sample_submission.csv.zip)

## How to solve the problem
1. Perform the necessary *Data Wrangling*.
2. Explore the data through descriptive summaries and visualizations.
3. Build predictive model (*most-likely decision trees*)
4. The final result of prediction should be in the form of the matches the submission template of the competition.


## The Deliverable
1. Capstone code, well-documented on [Home Depot Product Search Relevance Repo](https://github.com/MohammedFCIS/Home-Depot-Product-Search-Relevance).
2. A final paper explaining the problem, solution approach and any findings.
3. A slide deck for the project or a blog post for Springboard’s technical blog.