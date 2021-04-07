git add .
git commit -m "update"
git push -u origin main --force
hugo -D
cd public
git add .
git commit -m "update"
git push -u origin main --force