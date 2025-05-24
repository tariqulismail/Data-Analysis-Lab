

# Customer 360 Data Integration Project

## 📋 Overview
This project implements a comprehensive Customer 360 Data Integration solution that extracts, transforms, and loads customer-related data from various sources into a centralized data warehouse (Amazon Redshift). The goal is to create a unified customer view for analytics and business intelligence dashboards.

![Customer 360 Data Integration Mindmap](https://cdn1.genspark.ai/user-upload-image/imagen_generated/80467853-7a20-42be-bea0-fa73e9b2efcd)

## 🏗️ Architecture

The solution follows a modern data architecture with the following components:

- **Data Sources**: Multiple customer data touchpoints
- **Ingestion Layer**: Apache Airflow for orchestration
- **Staging Area**: Amazon S3 for raw data storage
- **Transformation Layer**: dbt for data modeling and transformation
- **Serving Layer**: Amazon Redshift as the data warehouse
- **BI Layer**: Power BI/Tableau for visualization and analytics

![Project Architecture](Customer360DataIntegrationArchitecture.png)


## 🔄 Data Pipeline

### Data Sources
- **CRM Data** (MySQL)
  - Generated with Faker library
  - Contains customer profile information
- **Salesforce Data**
  - Extracted via simple-salesforce Python package
  - Captures sales interactions and opportunities
- **Marketing Data** (Google Analytics)
  - BigQuery public datasets: `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  - Provides digital customer journey data
- **Offline Transactions** (CSV Files)
  - Generated with Mockaroo
  - Contains in-store/offline purchase information

### ETL Process
1. **Extract**: Airflow DAGs pull data from each source
2. **Load**: Raw data stored in S3 buckets
3. **Transform**: dbt models clean, standardize, and join data
4. **Validate**: great_expectations library ensures data quality
5. **Load**: Final models deployed to Amazon Redshift REPORTING schema

## 🛠️ Technologies

- **Orchestration**: Apache Airflow
- **Storage**: Amazon S3, Amazon Redshift
- **Transformation**: dbt (data build tool)
- **Data Validation**: great_expectations
- **Visualization**: Power BI/Tableau
- **Infrastructure**: Docker, GitHub Actions

## 📦 Project Structure

```
customer_360_project/
├── airflow/
│   └── dags/
│       ├── customer_360_extract.py
│       ├── load_to_redshift_staging.py
│       └── dbt_transform.py           # The DAG we're focusing on
├── dbt/
│   ├── models/
│   │   ├── staging/                   # Stage 1: Cleaned source data
│   │   │   ├── stg_crm_customers.sql
│   │   │   ├── stg_salesforce_contacts.sql
│   │   │   ├── stg_ga_sessions.sql
│   │   │   └── stg_transactions.sql
│   │   └── marts/                     # Stage 2: Business-specific models
│   │       ├── customer_360_profile.sql
│   │       ├── customer_engagement.sql
│   │       └── channel_attribution.sql
│   ├── dbt_project.yml               # dbt project configuration
│   ├── profiles.yml                  # Database connection profiles
│   └── packages.yml                  # dbt package dependencies
└── docker-compose.yml                # For containerization

```

## ⚙️ Setup and Installation

### Prerequisites
- Docker and Docker Compose
- AWS Account with S3 and Redshift access
- Salesforce Developer Account
- Python 3.8+

### Getting Started

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/customer_360.git
cd customer_360
```

2. **Set up environment variables**
```bash
cp .env.example .env
# Edit .env with your credentials
```

3. **Start the local environment**
```bash
docker-compose up -d
```

4. **Initialize Airflow connections**
```bash
docker-compose exec airflow airflow connections add 'aws_default' \
    --conn-type 'aws' \
    --conn-login '<your-access-key>' \
    --conn-password '<your-secret-key>' \
    --conn-extra '{"region_name": "us-east-1"}'
```

5. **Initialize dbt**
```bash
cd models
dbt deps
dbt seed
```

## 📊 Data Models

### Core Models

#### Customer 360 Unified Profile
- Combines data from all sources into a single customer view
- Includes demographic, behavioral, and transactional data
- Provides a 360-degree view of the customer journey

#### Customer Engagement Metrics
- Tracks customer interactions across channels
- Calculates engagement scores and activity levels
- Identifies preferred communication channels

#### Channel Attribution
- Attributes conversions to marketing channels
- Provides insight into the customer acquisition journey
- Helps optimize marketing spend


![Customer360OverviewDashboard](Customer360OverviewDashboard.png)


![CustomerJourney](CustomerJourney.png)


## 🔍 Monitoring & CI/CD

- **GitHub Actions**: Automated testing and deployment
- **Docker**: Containerized environment for consistent execution
- **dbt tests**: Data quality and integrity validation
- **Airflow monitoring**: DAG execution tracking and alerts

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Contact

If you have any questions or want to contribute, please reach out!

---

*This README is part of the Customer 360 Data Integration Project*
