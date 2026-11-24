import CoreGraphics

/// Discussions #637, not in Arc: how close the sidebar's rows sit. `.arc` is Arc 1.168's own,
/// measured at 2x (CraMetrics): a 40 pt row 1 pt under the one above it, a 41 pt pitch.
/// `.compact` keeps the favicon and title and gives up the air round them, so about a quarter
/// more tabs fit on a 13-inch screen. Yab's Compact (Prefs.swift, `Density`) takes its rows from
/// 41 to 32 pt; Cra's 32 pt row on the same 1 pt step lands on a 33 pt pitch, 80 % of Arc's.
public enum SidebarDensity: String, Codable, Sendable, CaseIterable {
    case arc
    case compact

    /// A tab, folder or New Tab row's height.
    public var rowHeight: CGFloat { self == .compact ? 32 : 40 }
    /// The gap between two rows.
    public var rowSpacing: CGFloat { 1 }
    /// A row's fill's corner: the same share of its shorter row.
    public var rowCorner: CGFloat { self == .compact ? 8 : 10 }
    /// Rows from the top of the list to `height` points down, for `rows` rows.
    public func height(rows: Int) -> CGFloat {
        rows <= 0 ? 0 : CGFloat(rows) * rowHeight + CGFloat(rows - 1) * rowSpacing
    }
}
