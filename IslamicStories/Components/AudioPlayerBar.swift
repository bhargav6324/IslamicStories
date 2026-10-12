import SwiftUI

public struct AudioPlayerBar: View {

    @Bindable private var narrationService: SpeechNarrationService

    public let isArabic: Bool
    public var onClose: (() -> Void)?

    @Environment(\.layoutDirection)
    private var layoutDirection

    public init(
        narrationService: SpeechNarrationService,
        isArabic: Bool = false,
        onClose: (() -> Void)? = nil
    ) {
        self.narrationService = narrationService
        self.isArabic = isArabic
        self.onClose = onClose
    }

    // MARK: - State

    private var totalSections: Int {
        max(0, narrationService.totalSectionsCount)
    }

    private var currentSection: Int {
        guard totalSections > 0 else { return 0 }

        return min(
            max(0, narrationService.currentSectionIndex),
            totalSections - 1
        )
    }

    private var hasContent: Bool {
        totalSections > 0
    }

    private var isPlaying: Bool {
        narrationService.isPlaying
    }

    private var canGoPrevious: Bool {
        hasContent && currentSection > 0
    }

    private var canGoNext: Bool {
        hasContent && currentSection < totalSections - 1
    }

    private var sectionProgress: Double {
        guard hasContent, totalSections > 0 else { return 0 }

        return Double(currentSection + 1) / Double(totalSections)
    }

    private var arabic: Bool {
        layoutDirection == .rightToLeft
    }

    private var playerTitle: String {
        arabic ? "القراءة الصوتية" : "Audio Narration"
    }

    private var sectionSubtitle: String {
        guard hasContent else {
            return arabic
                ? "لا يوجد محتوى صوتي جاهز"
                : "Narration not ready"
        }

        return arabic
            ? "القسم \(currentSection + 1) من \(totalSections)"
            : "Section \(currentSection + 1) of \(totalSections)"
    }

    // MARK: - Actions

    private func handlePlayPause() {
        guard hasContent else { return }

        narrationService.togglePlayPause()
    }

    private func handlePrevious() {
        guard canGoPrevious else { return }

        narrationService.previousSection()
    }

    private func handleNext() {
        guard canGoNext else { return }

        narrationService.nextSection()
    }

    private func handleClose() {
        narrationService.stop()
        onClose?()
    }

    // MARK: - Body

    public var body: some View {

        VStack(spacing: 0) {

            // Section-based progress
            if hasContent {
                ReadingProgressBar(
                    progress: sectionProgress,
                    height: 3
                )
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.sm)
                .accessibilityLabel(
                    arabic
                        ? "تقدم الأقسام"
                        : "Section progress"
                )
            }

            VStack(spacing: AppSpacing.sm) {

                // MARK: Header

                HStack(spacing: AppSpacing.sm) {

                    ZStack {
                        Circle()
                            .fill(
                                AppColors.emeraldGreen.opacity(0.12)
                            )
                            .frame(width: 38, height: 38)

                        Image(
                            systemName: isPlaying
                                ? "waveform"
                                : "headphones"
                        )
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.emeraldGreen)
                        .symbolEffect(
                            .variableColor.iterative,
                            isActive: isPlaying
                        )
                    }
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 3) {

                        Text(playerTitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppColors.charcoal)

                        Text(sectionSubtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: handleClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppColors.secondaryText)
                            .frame(width: 30, height: 30)
                            .background(
                                AppColors.secondaryCardBackground
                            )
                            .clipShape(Circle())
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        arabic ? "إغلاق" : "Close audio player"
                    )
                }

                // MARK: Playback Controls

                HStack(spacing: AppSpacing.sm) {

                    // Speed
                    Button {
                        narrationService.cyclePlaybackSpeed()
                    } label: {
                        Text(
                            String(
                                format: "%.2gx",
                                narrationService.playbackRateMultiplier
                            )
                        )
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.antiqueGold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            AppColors.secondaryCardBackground
                        )
                        .clipShape(Capsule())
                        .overlay {
                            Capsule()
                                .stroke(
                                    AppColors.goldBorder,
                                    lineWidth: 0.8
                                )
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        arabic ? "سرعة القراءة" : "Playback speed"
                    )

                    Spacer(minLength: 4)

                    // Transport controls cluster
                    HStack(spacing: AppSpacing.sm) {
                        // Previous section
                        Button(action: handlePrevious) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(AppColors.charcoal)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(!canGoPrevious)
                        .opacity(canGoPrevious ? 1 : 0.35)
                        .accessibilityLabel(
                            arabic ? "القسم السابق" : "Previous section"
                        )

                        // Play / Pause
                        Button(action: handlePlayPause) {
                            ZStack {
                                Circle()
                                    .fill(
                                        hasContent
                                            ? AppColors.emeraldGreen
                                            : AppColors.emeraldGreen.opacity(0.4)
                                    )
                                    .frame(width: 48, height: 48)

                                Image(
                                    systemName: isPlaying
                                        ? "pause.fill"
                                        : "play.fill"
                                )
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                            }
                            .frame(width: 50, height: 50)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(!hasContent)
                        .accessibilityLabel(
                            isPlaying
                                ? (arabic ? "إيقاف مؤقت" : "Pause narration")
                                : (arabic ? "تشغيل" : "Play narration")
                        )

                        // Next section
                        Button(action: handleNext) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(AppColors.charcoal)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(!canGoNext)
                        .opacity(canGoNext ? 1 : 0.35)
                        .accessibilityLabel(
                            arabic ? "القسم التالي" : "Next section"
                        )
                    }
                    .environment(\.layoutDirection, .leftToRight)

                    Spacer(minLength: 4)

                    // Visual balance for speed button to keep transport controls centered
                    Color.clear
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
        }
        .background {
            RoundedRectangle(
                cornerRadius: AppCornerRadius.lg
            )
            .fill(AppColors.cardBackground)
            .shadow(
                color: .black.opacity(0.12),
                radius: 14,
                x: 0,
                y: -4
            )
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: AppCornerRadius.lg
            )
            .stroke(AppColors.goldBorder, lineWidth: 1)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.bottom, AppSpacing.md)
    }
}