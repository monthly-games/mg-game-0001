# PowerShell script to apply VFX Manager patches to MG-0001
# Run this script from the game directory: d:/mg-games/repos/mg-game-0001

Write-Host "Applying VFX Manager Polish System to MG-0001..." -ForegroundColor Green

# File paths
$gameDir = "game/lib/game"
$towerDefenseFile = "$gameDir/tower_defense_game.dart"
$towerFile = "$gameDir/entities/tower.dart"
$bulletFile = "$gameDir/entities/bullet.dart"
$monsterFile = "$gameDir/entities/monster.dart"
$waveManagerFile = "$gameDir/core/wave_manager.dart"

Write-Host "`n1. Updating tower_defense_game.dart..." -ForegroundColor Yellow

# Read the file
$content = Get-Content $towerDefenseFile -Raw

# Add import
if ($content -notmatch "import 'core/vfx_manager.dart';") {
    $content = $content -replace "(import 'core/stage_data.dart';)", "`$1`nimport 'core/vfx_manager.dart';"
    Write-Host "  - Added vfx_manager import" -ForegroundColor Cyan
}

# Add vfxManager field
if ($content -notmatch "late final VfxManager vfxManager;") {
    $content = $content -replace "(late final WaveManager waveManager;)", "`$1`n  late final VfxManager vfxManager;"
    Write-Host "  - Added vfxManager field" -ForegroundColor Cyan
}

# Add vfxManager initialization
if ($content -notmatch "vfxManager = VfxManager\(\);") {
    $content = $content -replace "(camera\.viewfinder\.anchor = Anchor\.topLeft;)", "`$1`n`n    // Initialize VFX Manager`n    vfxManager = VfxManager();`n    add(vfxManager);"
    Write-Host "  - Added vfxManager initialization" -ForegroundColor Cyan
}

# Add build effect
if ($content -notmatch "vfxManager\.showTowerBuild") {
    $content = $content -replace "(\s+)(audio\.playSfx\('build\.wav'\);)", "`$1// Show build effect`n`$1vfxManager.showTowerBuild(position);`n`n`$1`$2"
    Write-Host "  - Added tower build effect" -ForegroundColor Cyan
}

# Add upgrade effect
if ($content -notmatch "vfxManager\.showTowerUpgrade") {
    $content = $content -replace "(_selectedTower!\.upgrade\(\);)", "`$1`n`n      // Show upgrade effect`n      vfxManager.showTowerUpgrade(_selectedTower!.position);"
    Write-Host "  - Added tower upgrade effect" -ForegroundColor Cyan
}

# Add wave complete effect
if ($content -notmatch "vfxManager\.showWaveComplete") {
    $content = $content -replace "(GetIt\.I<GoldManager>\(\)\.addGold\(stageReward\);)", "`$1`n`n    // Show wave complete effect`n    vfxManager.showWaveComplete(Vector2(size.x / 2, size.y / 2));"
    Write-Host "  - Added wave complete effect" -ForegroundColor Cyan
}

# Save the file
Set-Content -Path $towerDefenseFile -Value $content
Write-Host "  ✓ tower_defense_game.dart updated`n" -ForegroundColor Green

Write-Host "2. Updating tower.dart..." -ForegroundColor Yellow

# Read the file
$content = Get-Content $towerFile -Raw

# Add attack color method
if ($content -notmatch "_getAttackColor") {
    $colorMethod = @"
`n
  Color _getAttackColor() {
    switch (towerType) {
      case TowerType.basic:
        return Colors.yellow;
      case TowerType.splash:
        return Colors.orange;
      case TowerType.slow:
        return Colors.lightBlue;
      case TowerType.sniper:
        return Colors.red;
      case TowerType.air:
        return Colors.cyan;
      default:
        return Colors.white;
    }
  }
}
"@
    $content = $content -replace "}\s*$", $colorMethod
    Write-Host "  - Added _getAttackColor method" -ForegroundColor Cyan
}

# Add tower attack effect
if ($content -notmatch "vfxManager\.showTowerAttack") {
    $content = $content -replace "(if \(target != null\) \{)", "`$1`n      // Show tower attack effect`n      game.vfxManager.showTowerAttack(position, _getAttackColor());`n"
    Write-Host "  - Added tower attack effect call" -ForegroundColor Cyan
}

# Save the file
Set-Content -Path $towerFile -Value $content
Write-Host "  ✓ tower.dart updated`n" -ForegroundColor Green

Write-Host "3. Updating bullet.dart..." -ForegroundColor Yellow

# Read the file
$content = Get-Content $bulletFile -Raw

# Add splash impact effect
if ($content -notmatch "vfxManager\.showBulletImpact.*isSplash: true") {
    $content = $content -replace "(if \(isSplash\) \{\s+\/\/ Splash damage)", "if (isSplash) {`n      // Show splash impact effect`n      game.vfxManager.showBulletImpact(target.position, isSplash: true);`n`n      // Splash damage"
    Write-Host "  - Added splash impact effect" -ForegroundColor Cyan
}

# Add normal impact effect
if ($content -notmatch "vfxManager\.showBulletImpact.*isSplash: false") {
    $content = $content -replace "(\} else \{\s+)(target\.takeDamage\(damage\);)", "`$1// Show normal impact effect`n      game.vfxManager.showBulletImpact(target.position, isSplash: false);`n      `$2"
    Write-Host "  - Added normal impact effect" -ForegroundColor Cyan
}

# Save the file
Set-Content -Path $bulletFile -Value $content
Write-Host "  ✓ bullet.dart updated`n" -ForegroundColor Green

Write-Host "4. Updating monster.dart..." -ForegroundColor Yellow

# Read the file
$content = Get-Content $monsterFile -Raw

# Update takeDamage method
if ($content -notmatch "vfxManager\.showDamageNumber") {
    $content = $content -replace "(void takeDamage\(double amount\) \{\s+hp -= amount;)", "`$1`n`n    // Show damage number using VFX Manager`n    game.vfxManager.showDamageNumber(position, amount);"
    Write-Host "  - Added damage number effect" -ForegroundColor Cyan
}

# Add boss kill effect
if ($content -notmatch "vfxManager\.showBossKill") {
    $bossEffect = @"
      // Check if this is a boss
      final isBoss = monsterType == MonsterType.boss;

      if (isBoss) {
        // Show boss kill effect with screen shake
        game.vfxManager.showBossKill(position);
      } else {
        // Show monster death effect with gold reward
        game.vfxManager.showMonsterDeath(position, goldReward: goldReward);
      }

      // Reward Gold
"@
    $content = $content -replace "(\s+if \(hp <= 0\) \{\s+\/\/ Reward Gold)", "    if (hp <= 0) {`n$bossEffect"
    Write-Host "  - Added boss/monster death effects" -ForegroundColor Cyan
}

# Add slow effect
if ($content -notmatch "vfxManager\.showSlowEffect") {
    $content = $content -replace "(_slowDuration = duration;)", "`$1`n`n    // Show slow effect using VFX Manager`n    game.vfxManager.showSlowEffect(position);"
    Write-Host "  - Added slow effect" -ForegroundColor Cyan
}

# Save the file
Set-Content -Path $monsterFile -Value $content
Write-Host "  ✓ monster.dart updated`n" -ForegroundColor Green

Write-Host "5. Updating wave_manager.dart..." -ForegroundColor Yellow

# Read the file
$content = Get-Content $waveManagerFile -Raw

# Add wave complete effect
if ($content -notmatch "vfxManager\.showWaveComplete") {
    $waveEffect = @"
    _isWaveActive = false;

    // Show wave complete effect
    final centerPos = Vector2(
      game.size.x / 2,
      game.size.y / 2,
    );
    game.vfxManager.showWaveComplete(centerPos);

    // Check if Stage Complete
"@
    $content = $content -replace "(_isWaveActive = false;\s+\/\/ Check if Stage Complete)", $waveEffect
    Write-Host "  - Added wave complete effect" -ForegroundColor Cyan
}

# Save the file
Set-Content -Path $waveManagerFile -Value $content
Write-Host "  ✓ wave_manager.dart updated`n" -ForegroundColor Green

Write-Host "`n============================================" -ForegroundColor Green
Write-Host "VFX Manager Polish System Applied Successfully!" -ForegroundColor Green
Write-Host "============================================`n" -ForegroundColor Green

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run 'flutter pub get' to ensure dependencies are updated" -ForegroundColor White
Write-Host "2. Run 'flutter analyze' to check for any errors" -ForegroundColor White
Write-Host "3. Run the game and test the new visual effects" -ForegroundColor White
Write-Host "`nEffects added:" -ForegroundColor Yellow
Write-Host "  - Tower attack muzzle flashes" -ForegroundColor White
Write-Host "  - Monster death explosions" -ForegroundColor White
Write-Host "  - Bullet impact particles" -ForegroundColor White
Write-Host "  - Damage numbers" -ForegroundColor White
Write-Host "  - Tower build/upgrade celebrations" -ForegroundColor White
Write-Host "  - Wave completion celebrations" -ForegroundColor White
Write-Host "  - Boss kill screen shake" -ForegroundColor White
Write-Host "  - Slow effect indicators`n" -ForegroundColor White
