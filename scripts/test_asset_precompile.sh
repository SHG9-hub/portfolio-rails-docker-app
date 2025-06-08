#!/bin/bash

# Asset Precompilation Test Script
# This script helps test asset precompilation locally before deployment

echo "🧪 Asset Precompilation Test Script"
echo "====================================="

# Check for required environment variables
echo "🔍 Checking environment variables..."

required_vars=("RAILS_MASTER_KEY" "PGHOST" "PGUSER" "PGPASSWORD" "PGDATABASE")
missing_vars=()

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    else
        echo "✅ $var is set"
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo ""
    echo "❌ Missing required environment variables:"
    for var in "${missing_vars[@]}"; do
        echo "   - $var"
    done
    echo ""
    echo "💡 Please set the missing variables and try again:"
    echo "   export RAILS_MASTER_KEY=your_master_key"
    echo "   export PGHOST=your_db_host"
    echo "   export PGUSER=your_db_user"
    echo "   export PGPASSWORD=your_db_password"
    echo "   export PGDATABASE=your_db_name"
    exit 1
fi

echo ""
echo "🔧 Starting asset precompilation test..."

# Backup original database.yml if it exists
if [ -f config/database.yml ]; then
    echo "📁 Backing up config/database.yml"
    cp config/database.yml config/database_original.yml
fi

# Use precompile database configuration if available
if [ -f config/database_precompile.yml ]; then
    echo "📁 Using config/database_precompile.yml for precompilation"
    cp config/database_precompile.yml config/database.yml
else
    echo "⚠️ config/database_precompile.yml not found, using current database.yml"
fi

# Set environment and run asset precompilation
export RAILS_ENV=production
export SECRET_KEY_BASE_DUMMY=1

echo ""
echo "🎨 Running asset precompilation..."
echo "Environment: RAILS_ENV=$RAILS_ENV"
echo "Master Key: ${RAILS_MASTER_KEY:0:10}..."
echo "Database: $PGHOST/$PGDATABASE"

if bundle exec rails assets:precompile; then
    echo ""
    echo "✅ Asset precompilation completed successfully!"
else
    echo ""
    echo "❌ Asset precompilation failed!"
    
    # Restore original database.yml if backup exists
    if [ -f config/database_original.yml ]; then
        echo "📁 Restoring original database.yml"
        cp config/database_original.yml config/database.yml
    fi
    
    exit 1
fi

# Restore original database.yml if backup exists
if [ -f config/database_original.yml ]; then
    echo "📁 Restoring original database.yml"
    cp config/database_original.yml config/database.yml
fi

echo ""
echo "🎉 Asset precompilation test completed successfully!"
echo "Your application should be ready for deployment." 