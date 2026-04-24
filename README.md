# heartshift-demo
The demo version for HEARTSHIFT- a rhythm-visual novel hybrid game about a dream machine.


## Development Checklist

### Core Gameplay & Engine
- [ ] **Rework Wave Engine**: Transition away from trigonometric formulas to a more user-friendly system.
- [ ] **Wave Editor**: Develop an in-game tool for creating/editing waves (no Desmos required).
- [ ] **Rhythm Mechanics**:
    - [ ] Timed "hits" with input leeway.
    - [ ] Hold notes.
    - [ ] Unique/Experimental note types(?).
- [ ] **Sync System**: Ensure the wave engine is perfectly synced to the music track.
- [ ] **Dynamic Features**:
    - [ ] Mid-song scroll speed changes(possibly?).
    - [ ] Effect/Visual triggers for specific song segments.
    - [ ] Make the wave calm down into a regularised, smoother pattern toward the end of a song.
    - [ ] Pause functionality.
- [ ] **Scoring & Feedback**:
    - [ ] Point system and ranking logic (S/A/B/C).
    - [ ] Accuracy labels based on millisecond offset (e.g. Critical, Critical, Great, Good).
    - [ ] Difficulty labeling and life gauges.

### Narrative & Creative
- [ ] **Game Vision**: Define the core theme and story "hook."
- [ ] **Character Design**: Conceptualize and design the main cast.
- [ ] **World Building**: Establish the lore, setting, and history.
- [ ] **Story Outline**: Develop the plot using the **Snowflake Method** (iterative depth).

### Systems & UI
- [ ] **Visual Novel Engine**: System for dialogue, sprites, and narrative delivery.
- [ ] **Hybrid Integration**: Seamless flow between Story → Song → Mid-song Dialogue → Story.
- [ ] **Menu Suite**:
    - [ ] Main Menu.
    - [ ] Settings Panel (Volume controls, offset calibration, etc.).
    - [ ] Story Mode Level Selector.
    - [ ] Song Select Menu (Free play for official and community/custom songs).

### Future / Optional
- [ ] **Beat Analyzer**: ML model integration for automated rhythm analysis.
- [ ] **Internal Documentation**: Comprehensive guide on wave engine internals for team collaboration.

---

## Game Flow
1. **Story** (Visual Novel/VN Engine)
2. **Song** (Rhythm Engine)
3. **Mid-song events** (Integrated VN/Rhythm)
4. **Results** (Ranking & Accuracy)