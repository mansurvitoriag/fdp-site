$token = & "C:\Program Files\GitHub CLI\gh.exe" auth token
git remote set-url origin "https://mansurvitoriag:$token@github.com/mansurvitoriag/fdp-site.git"
git add .
git commit -m "atualizacao do site"
git push origin main
git remote set-url origin "https://github.com/mansurvitoriag/fdp-site.git"
Write-Host "`nSite atualizado! A Vercel vai publicar em instantes." -ForegroundColor Green
