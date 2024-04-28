//
//  HomeViewModel.swift
//  OtakuSigma
//
//  Created by Timmy Nguyen on 10/22/23.
//

import Foundation
import UIKit
import Combine

// @Published only works with structs (arrays/dicts are structs in swift)
@MainActor
class HomeViewModel: ObservableObject {
    @Published var selectedAnimeStatus: AnimeWatchListStatus = .watching
//    {
//        willSet { Task { await appState?.loadUserList(status: newValue) } }
//    }
    
    @Published var selectedMangaStatus: MangaReadListStatus = .reading
//    {
//        didSet { Task { await loadUserMangaList() } }
//    }
//    
    @Published var selectedMediaType: MediaType = .anime 
//    {
//        didSet {
//            if selectedMediaType == .anime {
//                Task { await loadUserAnimeList() }
//            } else {
//                Task { await loadUserMangaList() }
//            }
//        }
//    }
    @Published var filteredText = "" {
        didSet { filterTextValueChanged() }
    }
    @Published var filteredUserAnimeList: [Anime] = []
    @Published var filteredUserMangaList: [Manga] = []
    
//    var appState: AppState
    // @Published is a property wrapper that publishes change message only when the wrapped value has been set.
    // @Publish doesnt work with reference types (i.e. classes) because reference 'value' doesn't change, variable still points to the same reference while structs values do actually change.
    // Nested ObservableObjects are supported yet but u can do this https://stackoverflow.com/questions/58406287/how-to-tell-swiftui-views-to-bind-to-nested-observableobjects
    
    var appState: AppState?
    var authService: OAuthService
    let mediaService: MediaService
    
    var mediaImage: String {
        selectedMediaType == .anime ? "book" : "tv"
    }
        
    init(mediaService: MediaService, authService: OAuthService) {
        self.mediaService = mediaService
        self.authService = authService
//        
//        Task {
//            await appState.loadUserAnimeList()
//        }
        
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            print("Anime list: \(appState.userAnimeList[.watching]?.count)")
//        }

    }
    
    private func filterTextValueChanged() {
        guard let appState else { return }
        if selectedMediaType == .anime {
            if filteredText.isEmpty {
                filteredUserAnimeList = appState.userAnimeList[selectedAnimeStatus, default: []]
                return
            }
            filteredUserAnimeList = appState.userAnimeList[selectedAnimeStatus, default: []].filter { $0.title.lowercased().contains(filteredText.lowercased()) }
        } else {
            if filteredText.isEmpty { 
                filteredUserMangaList = appState.userMangaList[selectedMangaStatus, default: []]
                return
            }
            filteredUserMangaList = appState.userMangaList[selectedMangaStatus, default: []].filter { $0.title.lowercased().contains(filteredText.lowercased()) }
        }
    }
    
//    func loadUserAnimeList() async {
//        guard userAnimeList[selectedAnimeStatus, default: []].isEmpty else { return }
//        print(#function)
//        do {
//            userAnimeList[selectedAnimeStatus] = try await mediaService.getUserList(status: selectedAnimeStatus, sort: AnimeSort.listUpdatedAt, fields: Anime.fields)
//        } catch {
//            userAnimeList[selectedAnimeStatus] = []
//            print("Error getting user anime list. Check if access token is valid: \(error)")
//        }
//    }
//    
//    func loadUserMangaList() async {
//        guard userMangaList[selectedMangaStatus, default: []].isEmpty else { return }
//        print(#function)
//        do {
//            userMangaList[selectedMangaStatus] = try await mediaService.getUserList(status: selectedMangaStatus, sort: MangaSort.listUpdatedAt, fields: Manga.fields)
//        } catch {
//            userMangaList[selectedMangaStatus] = []
//            print("Error getting user manga list. Check if access token is valid: \(error)")
//        }
//    }
    
    func didTapMediaButton() {
        selectedMediaType = selectedMediaType == .anime ? .manga : .anime
    }
    
    func didTapLoginButton() {
        authService.showLogin()
    }
    
//    func getListStatus(for id: Int) -> ListStatus? {
//        for (_, animes) in userAnimeList {
//            if let anime = animes.first(where: { $0.id == id }) {
//                return anime.myListStatus
//            }
//        }
//        
//        for (_, mangas) in userMangaList {
//            if let manga = mangas.first(where: { $0.id == id }) {
//                return manga.myListStatus
//            }
//        }
//        
//        return nil
//    }
}
