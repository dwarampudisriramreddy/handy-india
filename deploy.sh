#!/bin/bash

echo "🚀 Starting Production Build for Handy India..."

# 1. Build the Flutter Web app
flutter build web --release --no-tree-shake-icons --base-href "/"

# 2. Prepare Netlify specific files
echo "📦 Preparing deployment files..."
cp build/web/index.html build/web/404.html
echo "/* /index.html 200" > build/web/_redirects

# 3. Create netlify.toml for extra safety
cat <<EOF > build/web/netlify.toml
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
EOF

echo "✅ Build complete. Deploying to HandyIndia (08571fb5-17c5-4570-aa2f-9367333a6e8b)..."

# 4. Deploy using CLI directly to the specific Site ID
netlify deploy --dir=build/web --prod --site 08571fb5-17c5-4570-aa2f-9367333a6e8b

echo "🎉 Deployment Successful!"
echo "Visit your site at: https://handyindia.netlify.app"
