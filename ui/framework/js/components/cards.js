/*
----------------------------------------
RIG Framework (built for CFX Platforms)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
*/

import { Buttons } from "../components/buttons.js"
import { resolve_image_path } from "../helpers.js"

export class Cards {
    constructor({ title = "", search = null, layout = {}, cards = [] }) {
        this.title = title;
        this.search = search;
        this.layout = layout;
        this.cards = Array.isArray(cards) ? cards : Object.values(cards);

        this.flex = layout.flex === "column" ? "column" : "row";
        this.scroll_y = layout.scroll_y === "none" ? "scroll_y_none" : layout.scroll_y === "auto" ? "scroll_y_auto" : "scroll_y_on";
        this.scroll_x = layout.scroll_x === "none" ? "scroll_x_none" : layout.scroll_x === "auto" ? "scroll_x_auto" : "scroll_x_on";
        this.grid_columns = Number(layout.columns) || 0;
    }

    get_html() {
        const style = this.grid_columns > 0 ? `style="grid-template-columns: repeat(${this.grid_columns}, 1fr);"` : "";
        const content = this.cards.map((c, i) => this.create_card(c, i)).join("");
        return `<div class="cards_container ${this.scroll_x} ${this.scroll_y}" ${style}>${content}</div>`.trim();
    }

    create_media(card) {
        const source = (card.image || card.icon || "").trim();
        if (!source) return "";

        const rarity = card.on_hover?.rarity?.toLowerCase() || "common";
        const rarity_class = rarity && rarity !== "common" ? `rarity_${rarity}` : "";

        let inner;
        
        if (source.startsWith("<svg")) {
            inner = `<span class="body_card_icon_svg">${source}</span>`;
        } else if (source.startsWith("http://") || source.startsWith("https://")) {
            inner = `<img class="body_card_icon_img" src="${source}" alt="" />`;
        } else if (/\.(svg|png|jpg|jpeg|webp)(\?.*)?$/i.test(source)) {
            inner = `<img class="body_card_icon_img" src="${resolve_image_path(source, "/ui/assets/images/")}" alt="" />`;
        } else {
            inner = `<i class="${source} body_card_icon_fa"></i>`;
        }

        return `<div class="body_card_image ${rarity_class}"><div class="body_card_image_wrapper">${inner}</div></div>`;
    }

    create_progress(card) {
        if (typeof card.progress !== "number") return "";
        const pct = Math.max(0, Math.min(100, card.progress));
        return `<div class="body_card_progress"><div class="body_card_progress_fill" style="width: ${pct}%;"></div></div>`;
    }

    create_card(card, index) {
        const title = card.title ? `<h4>${card.title}</h4>` : "";
        const desc = card.description ? `<p>${card.description}</p>` : "";
        const category = card.category?.toLowerCase() || "uncategorized";
        const dataset_attrs = card.dataset ? Object.entries(card.dataset).map(([k, v]) => `data-${k}="${String(v)}"`).join(" ") : "";
        const tooltip_data = card.on_hover ? `data-tooltip='${JSON.stringify({ on_hover: card.on_hover }).replace(/'/g, "&apos;").replace(/"/g, "&quot;")}'` : "";

        const rarity = card.on_hover?.rarity?.toLowerCase() || "common";
        const rarity_class = rarity && rarity !== "common" ? `rarity_${rarity}` : "";
        const media = this.create_media(card);
        const progress = this.create_progress(card);

        const buttons = Array.isArray(card.buttons) && card.buttons.length ? `<div class="body_card_actions">${new Buttons({
            buttons: card.buttons.map((b, i) => ({ ...b, id: b.id || `card_btn_${i}`, dataset: { card_id: card.id || `card_${index}`, ...(b.dataset || {}) } })),
            classes: "cards"
        }).get_html()}</div>` : "";

        return `<div class="body_card ${this.flex} ${rarity_class}" data-card-index="${index}" data-category="${category}" ${dataset_attrs} ${tooltip_data}>${media}<div class="body_card_info">${title}${desc}${progress}</div>${buttons}</div>`.trim();
    }

}