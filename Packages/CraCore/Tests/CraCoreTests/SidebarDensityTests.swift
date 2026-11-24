import Foundation
import Testing
@testable import CraCore

/// Discussions #637: a compact sidebar, its rows closer together than Arc's.
@Suite struct SidebarDensityTests {
    /// Arc's by default, an older settings.json without the key loads Arc's, and it's not reported.
    @Test func arcByDefault() throws {
        #expect(AppSettings().sidebarDensity == .arc)
        let s = try JSONDecoder().decode(AppSettings.self, from: Data("{}".utf8))
        #expect(s.sidebarDensity == .arc)
        #expect(UsageStats.unreportedSettings.contains("sidebarDensity"))
    }

    /// Saved and read back; a value from a newer Cra loads Arc's instead of failing the file.
    @Test func savedAndReadBack() throws {
        var s = AppSettings()
        s.sidebarDensity = .compact
        let back = try JSONDecoder().decode(AppSettings.self, from: JSONEncoder().encode(s))
        #expect(back.sidebarDensity == .compact)
        let unknown = try JSONDecoder().decode(AppSettings.self, from: Data(#"{"sidebarDensity":"tiny","translucentSidebar":true}"#.utf8))
        #expect(unknown.sidebarDensity == .arc, "an unknown density falls back to Arc's")
        #expect(unknown.translucentSidebar, "and the rest of the file still loads")
    }

    /// Arc's rows are Arc 1.168's 40 pt on a 41 pt pitch; compact's are 32 on 33, so 30 tabs take
    /// 989 pt where Arc's take 1,229, about a quarter more tabs in the same height.
    @Test func compactFitsAQuarterMore() {
        #expect(SidebarDensity.arc.rowHeight == 40 && SidebarDensity.arc.rowSpacing == 1 && SidebarDensity.arc.rowCorner == 10,
                "Arc's density keeps Arc's measured row")
        #expect(SidebarDensity.compact.rowHeight == 32 && SidebarDensity.compact.rowCorner == 8)
        #expect(SidebarDensity.arc.height(rows: 30) == 1229)
        #expect(SidebarDensity.compact.height(rows: 30) == 989)
        #expect(SidebarDensity.compact.height(rows: 0) == 0 && SidebarDensity.compact.height(rows: 1) == 32)
        let screen: CGFloat = 700
        let fit = { (d: SidebarDensity) in Int((screen + d.rowSpacing) / (d.rowHeight + d.rowSpacing)) }
        #expect(fit(.arc) == 17 && fit(.compact) == 21, "a 13-inch sidebar's 700 pt of tabs holds 21 rows, not 17")
    }
}

/// Discussions #637: compact favorites are shorter, not narrower, so the grid keeps Arc's columns.
@Suite struct CompactFavoritesTests {
    @Test func shorterTilesSameColumns() {
        let arc = FavoritesLayout(count: 6, width: 312)
        let compact = FavoritesLayout(count: 6, width: 312, density: .compact)
        #expect(arc.columns == compact.columns && arc.tileWidth == compact.tileWidth, "the columns stay Arc's")
        #expect(arc.frame(at: 4).height == 47 && compact.frame(at: 4).height == 36)
        #expect(arc.gridHeight == 2 * 47 + 8 && compact.gridHeight == 2 * 36 + 8)
        #expect(compact.frame(at: 3).minY == CGFloat(44), "the second row starts under the shorter first")
        #expect(compact.slot(at: CGPoint(x: 1, y: 40)) == 3 && arc.slot(at: CGPoint(x: 1, y: 40)) == 0,
                "a drop 40 pt down lands in compact's second row, Arc's first")
    }
}
