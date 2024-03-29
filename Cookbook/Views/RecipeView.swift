//
//  RecipeView.swift
//  Cookbook
//
//  Created by Matthew Klaybor on 2/13/24.
//

import SwiftUI
import SwiftData

struct RecipeView: View {
    let meal: Meal
    @Environment(CookbookRepository.self) var cookbookRepository
    @FetchRequest(sortDescriptors: []) var images: FetchedResults<CookbookImage>
    
    var body: some View {
        @Bindable var cookbookRepository = cookbookRepository
        VStack {
            if let recipe = cookbookRepository.recipes[meal.idMeal]?.first {
                List {
                    Section {
                        if let imageData = images.first(where: { $0.name == meal.strMealThumb })?.data, let image = UIImage(data: imageData) {
                            Image(uiImage: image).resizable().scaledToFit()
                        }
                        if let instructions = recipe.strInstructions {
                            Text(instructions)
                        }
                    } header: {
                        if let name = recipe.strMeal {
                            Text(name)
                                .bold()
                                .font(.title3)
                        }
                    }
                    
                    Section {
                        ForEach(recipe.ingredients) { ingredient in
                            HStack {
                                Text(ingredient.name)
                                Spacer()
                                Text(ingredient.measurement)
                            }
                        }
                    } header: {
                        Text(LocalizedStringKey("Ingredients"))
                            .bold()
                            .font(.title3)
                    }
                }
                .listStyle(.grouped)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(LocalizedStringKey("Recipe"))
        .task {
            await cookbookRepository.fetchRecipe(mealId: meal.idMeal)
        }
        .alert(LocalizedStringKey("Error"), isPresented: $cookbookRepository.errorFetchingRecipe, actions: {
            Button(LocalizedStringKey("Ok")) {}
            Button(LocalizedStringKey("Retry")) {
                Task { await cookbookRepository.fetchRecipe(mealId: meal.idMeal) }
            }
        }, message: {
            Text(LocalizedStringKey("serviceError"))
        })
    }
}

#Preview {
    Group {
        RecipeView(meal: .init(strMeal: "Apple & Blackberry Crumble", strMealThumb: "https://www.themealdb.com/images/media/meals/xvsurr1511719182.jpg", idMeal: "52893"))
        RecipeView(meal: .init(strMeal: "ProgressView / Error Test", strMealThumb: "", idMeal: ""))
    }
    .environment(CookbookRepository())
    .environment(\.managedObjectContext, PersistentContainer().container.viewContext)
}
