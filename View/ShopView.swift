//
//  ShopView.swift
//  Shiddaha
//
//  Created by AlAnoud Alsaaid on 22/08/1447 AH.
//

import SwiftUI

// MARK: - SHOP VIEW
struct ShopView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: OnboardingViewModel
    @State private var selectedCategory: StoreCategory = .tents
    @State private var showPurchaseConfirm = false
    @State private var showInsufficientFunds = false
    @State private var showSelectConfirm = false
    @State private var selectedItem: StoreItem?
    
    // 🎯 ADJUSTABLE POSITIONS
    private let backButtonSize: CGFloat = 40
    private let backButtonPadding: CGFloat = 16
    private let titleFontSize: CGFloat = 12
    private let dateLabelHeight: CGFloat = 30
    private let dateLabelFontSize: CGFloat = 10
    private let categoryButtonSize: CGFloat = 44
    private let categoryButtonPadding: CGFloat = 6
    private let categoryButtonSpacing: CGFloat = 12
    private let categorySelectedOpacity: CGFloat = 0.25
    private let gridSpacing: CGFloat = 14
    private let gridHorizontalPadding: CGFloat = 16
    private let cardCornerRadius: CGFloat = 16
    private let cardHeight: CGFloat = 120
    private let cardImageHeight: CGFloat = 70
    private let cardPadding: CGFloat = 10
    private let cardBorderWidth: CGFloat = 2
    private let dateTagHeight: CGFloat = 28
    private let checkmarkSize: CGFloat = 30
    
    // Alert sizing
    private let alertWidth: CGFloat = 320
    private let alertHeight: CGFloat = 240
    
    private let backgroundColor: String = "DDC59F"
    private let brownColor = Color(red: 0.35, green: 0.22, blue: 0.14)
    
    private let items: [StoreItem] = [
        // TENTS
        StoreItem(imageName: "tent", price: 0, category: .tents),
        StoreItem(imageName: "tent2", price: 180, category: .tents),
        StoreItem(imageName: "tent3", price: 180, category: .tents),
        StoreItem(imageName: "tent4", price: 180, category: .tents),
        StoreItem(imageName: "tent5", price: 180, category: .tents),
        StoreItem(imageName: "tent6", price: 180, category: .tents),
        
        // CHARACTERS
        StoreItem(imageName: "char_boy", price: 0, category: .characters),
        StoreItem(imageName: "char_girl", price: 0, category: .characters),
        StoreItem(imageName: "girl1", price: 180, category: .characters),
        StoreItem(imageName: "girl2", price: 180, category: .characters),
        StoreItem(imageName: "girl3", price: 180, category: .characters),
        StoreItem(imageName: "girl4", price: 180, category: .characters),
        StoreItem(imageName: "boy1", price: 180, category: .characters),
        StoreItem(imageName: "boy2", price: 180, category: .characters),
    ]
    
    private let visibleCategories: [StoreCategory] = [.tents, .characters]
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    private var filteredItems: [StoreItem] {
        items.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        ZStack {
            Color(hex: backgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                
                // TOP BAR
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.brown)
                            .padding(10)
                            .background(Color.white.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .frame(width: backButtonSize, height: backButtonSize)
                    
                    Spacer()
                    
                    Text("THE STORE")
                        .font(.custom("PressStart2P-Regular", size: titleFontSize))
                        .foregroundStyle(brownColor)
                    
                    Spacer()
                    
                    // 🎯 DATE COUNTER - Matches main page style
                    HStack(spacing: 30) {
                        Image("dates_icon")
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text("\(vm.datesCount)")
                            .font(.custom("PressStart2P-Regular", size: 16))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Image("score_box_bg")
                            .resizable()
                            .interpolation(.none)
                            .scaledToFill()
                    )
                }
                .padding(.horizontal, backButtonPadding)
                
                // CATEGORY BUTTONS
                HStack(spacing: categoryButtonSpacing) {
                    ForEach(visibleCategories) { cat in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedCategory = cat
                            }
                        } label: {
                            Image(cat.iconAssetName)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: categoryButtonSize, height: categoryButtonSize)
                                .padding(categoryButtonPadding)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedCategory == cat ? Color.brown.opacity(categorySelectedOpacity) : .clear)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // GRID
                ScrollView {
                    LazyVGrid(columns: columns, spacing: gridSpacing) {
                        ForEach(filteredItems) { item in
                            StoreItemCard(
                                item: item,
                                isPurchased: vm.isPurchased(item),
                                isSelected: selectedCategory == .tents ? vm.isTentSelected(item.imageName) : false,
                                cardCornerRadius: cardCornerRadius,
                                cardHeight: cardHeight,
                                cardImageHeight: cardImageHeight,
                                cardPadding: cardPadding,
                                cardBorderWidth: cardBorderWidth,
                                dateTagHeight: dateTagHeight,
                                dateLabelFontSize: dateLabelFontSize,
                                checkmarkSize: checkmarkSize
                            )
                            .onTapGesture {
                                handleItemTap(item)
                            }
                        }
                    }
                    .padding(.horizontal, gridHorizontalPadding)
                }
            }
            
            // 🎯 PURCHASE CONFIRMATION
            if showPurchaseConfirm {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                PurchaseConfirmAlert(
                    item: selectedItem,
                    onConfirm: {
                        confirmPurchase()
                    },
                    onCancel: {
                        withAnimation {
                            showPurchaseConfirm = false
                        }
                    },
                    alertWidth: alertWidth,
                    alertHeight: alertHeight
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            // 🎯 INSUFFICIENT FUNDS
            if showInsufficientFunds {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                InsufficientFundsAlert(
                    item: selectedItem,
                    currentDates: vm.datesCount,
                    onDismiss: {
                        withAnimation {
                            showInsufficientFunds = false
                        }
                    },
                    alertWidth: alertWidth,
                    alertHeight: alertHeight
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            // 🎯 SELECT CONFIRMATION
            if showSelectConfirm {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                SelectConfirmAlert(
                    item: selectedItem,
                    onDismiss: {
                        withAnimation {
                            showSelectConfirm = false
                        }
                    },
                    alertWidth: alertWidth,
                    alertHeight: alertHeight - 20
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // 🎯 HANDLE ITEM TAP
    private func handleItemTap(_ item: StoreItem) {
        selectedItem = item
        
        if vm.isPurchased(item) {
            // Already purchased - SELECT it
            if item.category == .tents {
                vm.selectTent(item.imageName)
                withAnimation {
                    showSelectConfirm = true
                }
            }
        } else {
            // Not purchased - try to BUY it
            if vm.datesCount >= item.price {
                withAnimation {
                    showPurchaseConfirm = true
                }
            } else {
                withAnimation {
                    showInsufficientFunds = true
                }
            }
        }
    }
    
    // 🎯 CONFIRM PURCHASE
    private func confirmPurchase() {
        guard let item = selectedItem else { return }
        
        if vm.purchaseItem(item) {
            withAnimation {
                showPurchaseConfirm = false
            }
            
            // Auto-select if it's a tent
            if item.category == .tents {
                vm.selectTent(item.imageName)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        showSelectConfirm = true
                    }
                }
            }
        }
    }
}

// MARK: - STORE ITEM CARD
struct StoreItemCard: View {
    let item: StoreItem
    let isPurchased: Bool
    let isSelected: Bool
    let cardCornerRadius: CGFloat
    let cardHeight: CGFloat
    let cardImageHeight: CGFloat
    let cardPadding: CGFloat
    let cardBorderWidth: CGFloat
    let dateTagHeight: CGFloat
    let dateLabelFontSize: CGFloat
    let checkmarkSize: CGFloat
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: cardCornerRadius)
                    .fill(Color.white.opacity(isPurchased ? 0.5 : 0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .stroke(isSelected ? Color.green : Color.brown.opacity(0.35), lineWidth: isSelected ? 4 : cardBorderWidth)
                    )
                    .frame(height: cardHeight)
                    .overlay(
                        Image(item.imageName)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(height: cardImageHeight)
                            .opacity(isPurchased && !isSelected ? 0.5 : 1.0)
                    )
                
                // ✅ CHECKMARK for selected tent
                if isSelected {
                    VStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: checkmarkSize))
                            .foregroundColor(.green)
                            .padding(8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }
            }
            
            // 🎯 PRICE TAG - Only show for unpurchased items
            if !isPurchased {
                HStack(spacing: 8) {
                    Image("dates_icon")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("\(item.price)")
                        .font(.custom("PressStart2P-Regular", size: dateLabelFontSize))
                        .foregroundStyle(Color(red: 0.30, green: 0.18, blue: 0.10))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "F6E5CB"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 0.30, green: 0.18, blue: 0.10), lineWidth: 2)
                        )
                )
            }
        }
        .padding(cardPadding)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius + 2)
                .fill(Color.brown.opacity(0.35))
        )
    }
}

// MARK: - PURCHASE CONFIRMATION ALERT
struct PurchaseConfirmAlert: View {
    let item: StoreItem?
    let onConfirm: () -> Void
    let onCancel: () -> Void
    let alertWidth: CGFloat
    let alertHeight: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "F6E5CB"))
                .frame(width: alertWidth, height: alertHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "8B4513"), lineWidth: 6)
                )
            
            VStack(spacing: 20) {
                Text("PURCHASE?")
                    .font(.custom("PressStart2P-Regular", size: 18))
                    .foregroundColor(.black)
                
                if let item = item {
                    Image(item.imageName)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(height: 80)
                    
                    HStack(spacing: 10) {
                        Text("Cost:")
                            .font(.custom("PressStart2P-Regular", size: 12))
                            .foregroundColor(.black.opacity(0.7))
                        
                        Text("\(item.price)")
                            .font(.custom("PressStart2P-Regular", size: 14))
                            .foregroundColor(Color(hex: "D32F2F"))
                        
                        Text("dates")
                            .font(.custom("PressStart2P-Regular", size: 10))
                            .foregroundColor(.black.opacity(0.7))
                    }
                }
                
                HStack(spacing: 15) {
                    Button(action: onCancel) {
                        Text("CANCEL")
                            .font(.custom("PressStart2P-Regular", size: 12))
                            .foregroundColor(.white)
                            .frame(width: 110, height: 45)
                            .background(Color.gray)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onConfirm) {
                        Text("BUY")
                            .font(.custom("PressStart2P-Regular", size: 12))
                            .foregroundColor(.white)
                            .frame(width: 110, height: 45)
                            .background(Color(hex: "4CAF50"))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: alertWidth, height: alertHeight)
        }
    }
}

// MARK: - SELECT CONFIRMATION ALERT
struct SelectConfirmAlert: View {
    let item: StoreItem?
    let onDismiss: () -> Void
    let alertWidth: CGFloat
    let alertHeight: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "F6E5CB"))
                .frame(width: alertWidth, height: alertHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "8B4513"), lineWidth: 6)
                )
            
            VStack(spacing: 20) {
                Text("SELECTED!")
                    .font(.custom("PressStart2P-Regular", size: 14))
                    .foregroundColor(Color(hex: "4CAF50"))
                
                if let item = item {
                    Image(item.imageName)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(height: 80)
                }
                
                Text("This item is now\nequipped!")
                    .font(.custom("PressStart2P-Regular", size: 12))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                
                Button(action: onDismiss) {
                    Text("OK")
                        .font(.custom("PressStart2P-Regular", size: 14))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 45)
                        .background(Color(hex: "4CAF50"))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .frame(width: alertWidth, height: alertHeight)
        }
    }
}

// MARK: - INSUFFICIENT FUNDS ALERT
struct InsufficientFundsAlert: View {
    let item: StoreItem?
    let currentDates: Int
    let onDismiss: () -> Void
    let alertWidth: CGFloat
    let alertHeight: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "F6E5CB"))
                .frame(width: alertWidth, height: alertHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "8B4513"), lineWidth: 6)
                )
            
            VStack(spacing: 20) {
                Text("NOT ENOUGH\nDATES!")
                    .font(.custom("PressStart2P-Regular", size: 16))
                    .foregroundColor(Color(hex: "D32F2F"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                if let item = item {
                    HStack(spacing: 15) {
                        VStack {
                            Text("You have:")
                                .font(.custom("PressStart2P-Regular", size: 10))
                                .foregroundColor(.black.opacity(0.7))
                            Text("\(currentDates)")
                                .font(.custom("PressStart2P-Regular", size: 10))
                                .foregroundColor(Color(hex: "D32F2F"))
                        }
                        
                        Text("")
                            .font(.custom("PressStart2P-Regular", size: 14))
                        
                        VStack {
                            Text("You need:")
                                .font(.custom("PressStart2P-Regular", size: 10))
                                .foregroundColor(.black.opacity(0.7))
                            Text("\(item.price)")
                                .font(.custom("PressStart2P-Regular", size: 14))
                                .foregroundColor(Color(hex: "4CAF50"))
                        }
                    }
                }
                
                Text("Complete more focus\nsessions to earn dates!")
                    .font(.custom("PressStart2P-Regular", size: 10))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                
                Button(action: onDismiss) {
                    Text("OK")
                        .font(.custom("PressStart2P-Regular", size: 14))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 45)
                        .background(Color(hex: "D32F2F"))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .frame(width: alertWidth, height: alertHeight)
        }
    }
}
