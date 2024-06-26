//
//  DiscoverViewModel.swift
//  OtakuSigma
//
//  Created by Timmy Nguyen on 10/22/23.
//

import Foundation
import Combine

@MainActor
class DiscoverViewModel: ObservableObject {
    @Published var selectedMediaType: MediaType = .anime
    @Published var searchText = ""
    @Published var animeSearchResult: [Anime] = []
    @Published var mangaSearchResult: [Manga] = []
    @Published var animeList: [MediaSection<Anime>] = []
    @Published var mangaList: [MediaSection<Manga>] = []

    var searchResult: [any Media] { selectedMediaType == .anime ? animeSearchResult : mangaSearchResult }
    
    let mediaService: MediaService
    
    var title: String {
        return selectedMediaType == .anime ? "Discover Anime" : "Discover Manga"
    }
    
    var hint: String {
        return selectedMediaType == .anime ? "Search Anime" : "Search Mangas, Novels, etc"
    }
        
    // Dependency Injection (allows different implementations, modular)
    init(mediaService: MediaService) {
        self.mediaService = mediaService

        Task {
            await loadMedia()
        }
    }
    
    func loadMedia() async {
        do {
            for ranking in AnimeRanking.allCases {
                let animes: [Anime] = try await mediaService.getMediaRanking(rankingType: ranking.type, limit: 10, offset: 0)
                let section = MediaSection(ranking: ranking, items: animes)
                animeList.append(section)
            }
            
            for ranking in MangaRanking.allCases {
                let mangas: [Manga] = try await mediaService.getMediaRanking(rankingType: ranking.type,  limit: 10, offset: 0)
                let section = MediaSection(ranking: ranking, items: mangas)
                mangaList.append(section)
            }
            
        } catch {
            print("[DiscoverViewModel] Error loading animes: \(error)")
        }
    }

    func submitButtonTapped() {
        fetchAnimeOrManga()
    }
    
    func searchTextValueChanged() {
        fetchAnimeOrManga()
    }
    
    private func fetchAnimeOrManga() {
        guard !searchText.isEmpty else { return }
        
        Task {
            do {
                if selectedMediaType == .anime {
                    animeSearchResult = try await mediaService.getMediaItems(title: searchText)
                    print(animeSearchResult.count)
                } else {
                    mangaSearchResult = try await mediaService.getMediaItems(title: searchText)
                }
            } catch {
                print("Error fetching: \(error)")
                selectedMediaType == .anime ? animeSearchResult.removeAll() : mangaSearchResult.removeAll()
            }
        }
    }
}

enum MediaType: String, CaseIterable, Identifiable {
    case anime, manga
    var id: Self { self }
}

protocol Ranking {
    var type: String { get }
    var description: String { get }
}

enum AnimeRanking: String, CaseIterable, CustomStringConvertible, Ranking {
    case airing, upcoming, all, movie, bypopularity, favorite
    
    var type: String { self.rawValue }
    
    var description: String {
        let currentSeason = Date().season
        let currentYear = Calendar.current.component(.year, from: .now)
        switch self {
        case .airing:
            return "Current Season - \(currentSeason.rawValue.capitalized) \(currentYear)"
        case .upcoming:
            let seasons = Season.allCases
            let index = seasons.firstIndex(of: currentSeason)!
            let nextSeason = seasons[(index + 1) % 4]
            let nextYear = currentSeason != .fall ? currentYear : currentYear + 1
            return "Upcoming Season - \(nextSeason.rawValue.capitalized) \(nextYear)"
        case .all:
            return "Top Anime Series"
        case .movie:
            return "Top Anime Movies"
        case .bypopularity:
            return "Popular Anime"
        case .favorite:
            return "Most Favorite"
        }
    }
}

enum MangaRanking: String, CaseIterable, Ranking {
    case manga, novels, manhwa, manhua, bypopularity, oneshots
    var type: String { self.rawValue }
    var description: String {
        switch self {
        case .manga:
            return "Top Manga"
        case .novels:
            return "Top Novels"
        case .manhwa:
            return "Top Manhwa"
        case .manhua:
            return "Top Manhua"
        case .bypopularity:
            return "Most Popular"
        case .oneshots:
            return "Top One-shots"
        }
    }
}

struct MediaSection<T: Media>: Identifiable {
    var ranking: Ranking
    var items: [T]
    var id: UUID { UUID() }
}
