# Override skim to add path-aware scoring: boost match positions in the
# filename (after the last '/') so filename matches rank above directory matches.
{ pkgs }:
pkgs.skim.overrideAttrs (old: {
  doCheck = false;
  postPatch =
    (old.postPatch or "")
    + ''
      # --- arinae algorithm ---

      # Add basename bonus constant
      sed -i '/pub(super) const TYPO_PENALTY/i\
      /// Bonus added to every character position after the last path separator.\
      /// Makes the fuzzy scorer inherently prefer filename over directory matches.\
      pub(super) const PATH_BASENAME_BONUS: Score = 30;' \
        src/fuzzy_matcher/arinae/constants.rs

      # Boost all positions after the last '/' in precompute_bonuses
      sed -i '/buf\.extend(bonus_iter);/a\
      \    // Boost filename positions (after last path separator)\
      \    if let Some(pos) = cho.iter().rposition(|c| { let ch: char = (*c).into(); ch == '"'"'/'"'"' }) {\
      \        for b in buf[pos + 1..].iter_mut() {\
      \            *b = b.saturating_add(PATH_BASENAME_BONUS);\
      \        }\
      \    }' \
        src/fuzzy_matcher/arinae/mod.rs

      # --- fzy algorithm ---

      # Add basename bonus constant
      sed -i '/const SCORE_TYPO/i\
      const PATH_BASENAME_BONUS: i64 = 50;' \
        src/fuzzy_matcher/fzy.rs

      # Boost all positions after the last '/' in precompute_bonus
      sed -i '/let mut bonuses = Vec::with_capacity/,/^}/c\
      \    let mut bonuses = Vec::with_capacity(haystack.len());\
      \    let mut prev = '"'"'/'"'"';\
      \    for \&ch in haystack {\
      \        bonuses.push(compute_bonus(prev, ch));\
      \        prev = ch;\
      \    }\
      \    // Boost filename positions (after last path separator)\
      \    if let Some(pos) = haystack.iter().rposition(|c| *c == '"'"'/'"'"') {\
      \        for b in bonuses[pos + 1..].iter_mut() {\
      \            *b += PATH_BASENAME_BONUS;\
      \        }\
      \    }\
      \    bonuses\
      \}' \
        src/fuzzy_matcher/fzy.rs
    '';
})
