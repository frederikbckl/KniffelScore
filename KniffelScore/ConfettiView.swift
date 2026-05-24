import SwiftUI

/// One-shot confetti burst: two cannons fire from the bottom corners,
/// particles arc upward then fall off screen. Stops itself after ~4 s.
struct ConfettiView: View {

    // MARK: - Particle model

    private struct Particle {
        let sx: CGFloat    // normalised start-x   (0…1)
        let vx: CGFloat    // normalised horiz vel  (units · s⁻¹, + = right)
        let vy: CGFloat    // normalised vert vel   (units · s⁻¹, − = up)
        let g:  CGFloat    // normalised gravity    (units · s⁻²)
        let spin:  Double  // initial rotation (°)
        let rpm:   Double  // rotation speed   (° · s⁻¹)
        let color: Color
        let w: CGFloat     // width  (pt)
        let h: CGFloat     // height (pt)
        let delay: Double  // launch delay (s)
    }

    // MARK: - Palette

    private static let palette: [Color] = [
        .appPrimary,
        Color(red: 167/255, green: 139/255, blue: 250/255),  // violet-400
        .appGreen,
        Color(red:  52/255, green: 211/255, blue: 153/255),  // emerald-400
        Color(red: 251/255, green: 191/255, blue:  36/255),  // amber-400
        Color(red: 248/255, green: 113/255, blue: 113/255),  // rose-400
        .white,
    ]

    // MARK: - State

    private let particles: [Particle]
    @State private var startDate: Date = .now
    @State private var running   = true

    // MARK: - Init

    init(count: Int = 160) {
        let pal = Self.palette
        particles = (0..<count).map { i in
            let fromLeft = i.isMultiple(of: 2)
            return Particle(
                sx:    fromLeft ? .random(in: 0.00...0.20) : .random(in: 0.80...1.00),
                vx:    fromLeft ? .random(in: 0.08...0.40) : .random(in: -0.40...(-0.08)),
                vy:    .random(in: -1.05...(-0.55)),
                g:     .random(in: 0.38...0.50),
                spin:  .random(in: 0...360),
                rpm:   .random(in: -500...500),
                color: pal.randomElement()!,
                w:     .random(in: 6...14),
                h:     .random(in: 9...20),
                delay: .random(in: 0...0.20)
            )
        }
    }

    // MARK: - Body

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60, paused: !running)) { tl in
            let elapsed = tl.date.timeIntervalSince(startDate)
            Canvas { ctx, size in
                for p in particles {
                    let dt = max(0, elapsed - p.delay)
                    let x  = p.sx * size.width  + p.vx * size.width  * dt
                    let y  = size.height
                           + p.vy * size.height * dt
                           + 0.5  * p.g * size.height * dt * dt

                    // Skip once off-screen or outside horizontal bounds
                    guard y < size.height + 40,
                          x > -20, x < size.width + 20 else { continue }

                    // Fade out in the bottom 15 % of the screen
                    let fade = max(0, min(1,
                        1 - max(0, (y - size.height * 0.85) / (size.height * 0.15))
                    ))

                    var c = ctx           // value-type copy → independent transform
                    c.opacity = fade
                    c.translateBy(x: x, y: y)
                    c.rotate(by: .degrees(p.spin + p.rpm * dt))
                    c.fill(
                        Path(roundedRect: CGRect(x: -p.w / 2, y: -p.h / 2,
                                                  width: p.w,  height: p.h),
                             cornerRadius: 2),
                        with: .color(p.color)
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            startDate = .now      // anchor to the exact moment the view appears
            Task {
                try? await Task.sleep(for: .seconds(6.0))
                running = false   // pause TimelineView; last frame is empty
            }
        }
    }
}
