//
//  WaterfallLayout.swift
//  WaterfallLayoutDemo
//
//  Created by Tao Xu on 1/14/25.
//

import UIKit

protocol WaterfallLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, photoSizeForItemAt indexPath: IndexPath) -> CGSize
}


/**
 - prepare(): Whenever a layout operation is about to take place, UIKit calls this method. It’s your opportunity to prepare and perform any calculations required to determine the collection view’s size and the positions of the items.
 
 - collectionViewContentSize: This method returns the width and height of the collection view’s contents. You must implement it to return the height and width of the entire collection view’s content, not just the visible content. The collection view uses this information internally to configure its scroll view’s content size.
 
 - layoutAttributesForElements(in:): In this method, you return the layout attributes for all items inside the given rectangle. You return the attributes to the collection view as an array of UICollectionViewLayoutAttributes.
 
 - layoutAttributesForItem(at:): This method provides on demand layout information to the collection view. You need to override it and return the layout attributes for the item at the requested indexPath.
 */
final class WaterfallLayout: UICollectionViewLayout {
    private let numberOfColumns: Int = 2
    private let itemSpacing: CGFloat = 10
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
          return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    private(set) var contentHeight: CGFloat = 0
    private(set) var cache:[UICollectionViewLayoutAttributes] = []
    weak var delegate: WaterfallLayoutDelegate?
    
    override func prepare() {
        super.prepare()
        guard let collectionView else { return }
        guard let delegate else { return }
        if collectionView.numberOfSections == 0 ||
            collectionView.numberOfItems(inSection: 0) == 0 {
            return
        }
        let totoalCount = collectionView.numberOfItems(inSection: 0)
        let columnWidth = collectionView.bounds.width / CGFloat(numberOfColumns)
        var xOffsets: [CGFloat] = []
        var yOffsets: [CGFloat] = []
        for i in 0..<numberOfColumns {
            xOffsets.append(CGFloat(i) * columnWidth)
            yOffsets.append(0)
        }
        var col = 0
        for i in 0..<totoalCount {
            let indexPath = IndexPath(item: i, section: 0)
            let photoSize = delegate.collectionView(collectionView, photoSizeForItemAt: indexPath)
            var columnHeight:CGFloat = columnWidth
            let w = photoSize.width
            let h = photoSize.height
            columnHeight = columnWidth * h / w
            let frame = CGRectMake(xOffsets[col], yOffsets[col], columnWidth, columnHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            self.cache.append(attributes)
            contentHeight = max(contentHeight, frame.maxY)
            yOffsets[col] += columnHeight
            
            col = col == numberOfColumns - 1 ? 0 : col + 1
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if cache.isEmpty { return nil }
        var results:[UICollectionViewLayoutAttributes] = []
        for layoutAttributes in cache {
            if layoutAttributes.frame.intersects(rect) {
                results.append(layoutAttributes)
            }
        }
        return results
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if cache.isEmpty { return nil }
        return cache[indexPath.item]
    }
}
