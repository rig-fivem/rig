/*
----------------------------------------
RIG Framework (built for CFX Platforms)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
*/

export class Notify {
    constructor({ position = "top-right", fill_direction = "down" } = {}) {
        this.position = position;
        this.fill_direction = fill_direction;
        this.container_id = "notify_container";
        this.create_container();
    }

    create_container() {
        if ($(`#${this.container_id}`).length) return;
        const style = this.resolve_position_style();
        const dir = this.fill_direction === "up" ? "column-reverse" : "column";
        $("body").append(`<div id="${this.container_id}" class="notify_container" style="position:absolute;${style.position};display:flex;flex-direction:${dir};align-items:${style.align};justify-content:${style.justify};gap:1.5vh;z-index:9999;pointer-events:none;"></div>`);
    }

    resolve_position_style() {
        const map = {
            "top-left": { position: "top:2vh;left:2vw;", align: "flex-start", justify: "flex-start" },
            "top-center": { position: "top:2vh;left:50%;transform:translateX(-50%);", align: "center", justify: "flex-start" },
            "top-right": { position: "top:2vh;right:2vw;", align: "flex-end", justify: "flex-start" },
            "bottom-left": { position: "bottom:2vh;left:2vw;", align: "flex-start", justify: "flex-end" },
            "bottom-center": { position: "bottom:2vh;left:50%;transform:translateX(-50%);", align: "center", justify: "flex-end" },
            "bottom-right": { position: "bottom:2vh;right:2vw;", align: "flex-end", justify: "flex-end" },
            "left-top": { position: "top:2vh;left:2vw;", align: "flex-start", justify: "flex-start" },
            "left-center": { position: "top:50%;left:2vw;transform:translateY(-50%);", align: "flex-start", justify: "center" },
            "left-bottom": { position: "bottom:2vh;left:2vw;", align: "flex-start", justify: "flex-end" },
            "right-top": { position: "top:2vh;right:2vw;", align: "flex-end", justify: "flex-start" },
            "right-center": { position: "top:50%;right:2vw;transform:translateY(-50%);", align: "flex-end", justify: "center" },
            "right-bottom": { position: "bottom:2vh;right:2vw;", align: "flex-end", justify: "flex-end" }
        };
        return map[this.position] || map["top-right"];
    }

    resolve_icon_html(icon) {
        if (!icon) return "";

        const trimmed = icon.trim();

        if (trimmed.startsWith("<svg")) {
            return `<span class="notify_icon notify_icon_svg">${trimmed}</span>`;
        }

        if (/\.(svg|png|jpg|jpeg|webp)$/i.test(trimmed)) {
            return `<img class="notify_icon notify_icon_img" src="${trimmed}" alt="" />`;
        }
        
        return `<i class="${trimmed} notify_icon notify_icon_fa"></i>`;
    }

    show({ type = "info", header = null, message = "", duration = 4000, icon = null }) {
        if (!message) return;
        const icon_html = this.resolve_icon_html(icon);
        const has_duration = duration > 0;
        const notify = `
            <div class="notify notify_${type} ${has_duration ? 'notify_has_bar' : ''}">
                ${header ? `<div class="notify_header">${icon_html}${header}</div>` : `<div class="notify_body" style="padding-top: 1vh;">${icon_html}${message}</div>`}
                ${header ? `<div class="notify_body">${message}</div>` : ""}
                ${has_duration ? `<div class="notify_bar"><div class="notify_fill"></div></div>` : ""}
            </div>
        `;
        const $el = $(notify);
        $(`#${this.container_id}`).append($el);
        if (has_duration) {
            $el.find(".notify_fill").animate({ width: "0%" }, duration, "linear");
            setTimeout(() => $el.fadeOut(300, () => $el.remove()), duration + 100);
        }
    }
}