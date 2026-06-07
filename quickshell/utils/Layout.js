.pragma library

/**
 * Returns the index of targetItem among its parent's visible children.
 * 
 * @param {Item} targetItem The item to find the index for.
 * @returns {number} The visible index, or -1 if not found or no parent exists.
 */
function visibleIndex(targetItem) {
    const parent = targetItem.parent;
    if (!parent) return -1;

    let index = 0;
    for (let i = 0; i < parent.children.length; i++) {
        const child = parent.children[i];
        if (child === targetItem) return index;
        if (child.visible) index++;
    }
    return -1;
}

/**
 * Returns the total number of visible children in a container.
 * 
 * @param {Item} container The parent item to check.
 * @returns {number} The number of visible children.
 */
function visibleCount(container) {
    if (!container) return 0;
    let count = 0;
    for (let i = 0; i < container.children.length; i++) {
        if (container.children[i].visible) count++;
    }
    return count;
}
