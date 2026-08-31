/*
----------------------------------------
RIG Framework (built for CFX Platforms)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
*/

import { Cards } from "./cards.js";
import { InputGroups } from "./input_groups.js";

export class Content {
    constructor(pages = {}, classes = "", layout = { left: 1, center: 2, right: 1 }) {
        this.pages = pages;
        this.classes = classes;
        this.layout = layout;

        this.page_items = Object.create(null);
        this.current_page_id = null;
    }

    get_html() {
        const sections_html = ["left", "center", "right"].map(s => `
            <div class="content_section ${s}" style="grid-column: span ${this.layout[s] || 0};">
                <div class="content_title ${s}"></div><div class="content_body ${s}"></div>
            </div>`).join("");

        return `<div class="content_grid ${this.classes}">${sections_html}</div>`.trim();
    }

    append_to(container = "#ui_main") {
        $(container).append(this.get_html());
    }

    async show_page(id) {
        this.current_page_id = id;

        const config = this.pages[id];
        if (!config || typeof config !== "object") {
            $(".content_body.center").html(`<div class="placeholder_content"></div>`);
            return;
        }

        for (const s of ["left", "center", "right"]) {
            $(`.content_section.${s}`).hide();
        }

        const layout = config.layout || this.layout;
        const content_keys = ["left", "center", "right"];
        let current_col = 1;

        for (const key of content_keys) {
            const span = Number(layout[key]) || 0;
            if (span <= 0) continue;

            const section = config[key] || null;
            const $section = $(`.content_section.${key}`);
            const $title = $section.find(`.content_title.${key}`);
            const $body = $section.find(`.content_body.${key}`);

            $section.css("grid-column", `${current_col} / span ${span}`).show();
            $title.empty();
            $body.empty();

            if (!section) {
                $body.html(`<div class="placeholder_section"></div>`);
                current_col += span;
                continue;
            }

            if (section.title) {
                $title.html(
                    typeof section.title === "object"
                        ? `<h3>${section.title.text}${section.title.span ? ` <span>${section.title.span}</span>` : ""}</h3>`
                        : `<h3>${section.title}</h3>`
                );
            }

            const html = await this.render_content(section);
            $body.html(html);

            current_col += span;
        }

        window.ui_instance?.tooltip?.bind_tooltips();
    }

    set_content(html, section = "center") {
        $(`.content_body.${section}`).html(html);
    }

    clear() {
        $(".content_body, .content_title").empty();
    }

    async render_content(data) {
        const map = {
            cards: () => this.build_cards(data),
            input_groups: () => this.build_input_groups(data)
        };
        return map[data.type]?.() || "";
    }

    build_cards(data) {
        return new Cards(data).get_html();
    }

    build_input_groups(data) {
        return new InputGroups({
            id: data.id || "input_groups",
            title: data.title || "",
            layout: data.layout || {},
            groups: Array.isArray(data.groups) ? data.groups : Object.values(data.groups || {}),
            buttons: Array.isArray(data.buttons) ? data.buttons : Object.values(data.buttons || {})
        }).get_html();
    }
}