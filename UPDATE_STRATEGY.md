# Safe Update Strategy

## Problem
The screens I modified had build errors because I changed too much structure.

## New Approach
**MINIMAL CHANGES ONLY:**
1. Keep exact same widget structure
2. Only update colors to AppTheme colors
3. Replace hardcoded colors like Colors.indigo with AppTheme.primaryPurple
4. Replace hardcoded Colors.amber with AppTheme.warning
5. Keep all methods, all logic, all widgets exactly as they are

## What NOT to Change
- Widget hierarchy
- Method signatures  
- State management
- Business logic
- Navigation
- Any imports that are already working

## What TO Change
- Colors.indigo -> AppTheme.primaryPurple
- Colors.amber -> AppTheme.warning
- Colors.green -> AppTheme.success
- Colors.red -> AppTheme.error
- BorderRadius values to AppTheme.radius*
- Add some spacing constants

This way the code will definitely build and work!
