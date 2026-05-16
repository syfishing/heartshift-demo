# heartshift-demo
The demo version for HEARTSHIFT- a rhythm-visual novel hybrid game about a dream machine.

## Important note
This is a team project performed by 4 people: Syfish, Haseeb, Jolly and Spooky.
Jolly and Spooky haven't worked on the project yet however.
This project is submitted to https://macondo.hackclub.com too, currently with separate projects for every team member until macondo has implemented team projects.

## Story/writing note
Syfish's writing of the story, lore, characters, worldbuilding etc is tracked with Hack Club's Hackatime but is put into the .gitignore file to prevent spoiling the entire future story as we plan to progressively release the story during our Early Access period on Steam after we release our demo (this repo!) on itch.io. We have permission for this from the organisers at Macondo after asking them! Dialogue in the demo will probably still be in the repo though as it will actually be inside the demo!

## Development Checklist

### Core Gameplay & Engine
- [x] **Rework Wave Engine**: Transition away from trigonometric formulas to a more user-friendly system.
- [ ] **Wave Editor**: Develop an in-game tool for creating/editing waves (no Desmos required).
- [x] **Rhythm Mechanics**:
    - [x] Timed "hits" with input leeway.
    - [x] Hold notes.
    - [ ] Unique/Experimental note types(?).
- [x] **Sync System**: Ensure the wave engine is perfectly synced to the music track.
- [ ] **Dynamic Features**:
    - [x] Mid-song scroll speed changes(possibly?).
    - [ ] Effect/Visual triggers for specific song segments.
    - [x] Make the wave calm down into a regularised, smoother pattern toward the end of a song.
    - [ ] Pause functionality.
- [ ] **Scoring & Feedback**:
    - [ ] Point system and ranking logic (S/A/B/C).
    - [x] Accuracy labels (e.g. Dreamy, Dreamy, Great, Good, Fail).
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