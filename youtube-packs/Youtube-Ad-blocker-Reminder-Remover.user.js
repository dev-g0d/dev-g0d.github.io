// ==UserScript==
// @name         RemoveAdblockThing Enchance
// @namespace    http://tampermonkey.net/
// @version      6.0
// @description  Removes Adblock Thing
// @author       JoelMatic
// @match        https://www.youtube.com/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=youtube.com
// @updateURL    https://github.com/TheRealJoelmatic/RemoveAdblockThing/raw/main/Youtube-Ad-blocker-Reminder-Remover.user.js
// @downloadURL  https://github.com/TheRealJoelmatic/RemoveAdblockThing/raw/main/Youtube-Ad-blocker-Reminder-Remover.user.js
// @grant        none
// ==/UserScript==

(function() {
    //
    // Config
    //
    const config = {
        adblocker: true,
        removePopup: false,
        updateCheck: true,
        fixTimestamps: true,
        debugMessages: true,
        updateModal: {
            enable: true,
            timer: 5000
        }
    };

    //
    // Variables
    //
    let currentUrl = window.location.href;
    let isAdFound = false;
    let adLoop = 0;
    let hasIgnoredUpdate = false;
    let videoPlayback = 1;

    //
    // Simulated Click Event
    //
    const clickEvent = new PointerEvent('click', {
        bubbles: true,
        cancelable: true,
        view: window,
        detail: 1,
        buttons: 1,
        pointerType: 'mouse',
        isPrimary: true
    });

    //
    // Setup
    //
    log("Script started");
    if (config.adblocker) removeAds();
    if (config.removePopup) popupRemover();
    if (config.updateCheck) checkForUpdate();
    if (config.fixTimestamps) timestampFix();

    //
    // Functions
    //
    function popupRemover() {
        setInterval(() => {
            const modalOverlay = document.querySelector("tp-yt-iron-overlay-backdrop");
            const popup = document.querySelector(".style-scope ytd-enforcement-message-view-model");
            const popupButton = document.getElementById("dismiss-button");
            const video = document.querySelector('video');
            document.body.style.setProperty('overflow-y', 'auto', 'important');

            if (modalOverlay) {
                modalOverlay.removeAttribute("opened");
                modalOverlay.remove();
            }

            if (popup) {
                log("Popup detected, removing...");
                if (popupButton) popupButton.dispatchEvent(clickEvent);
                popup.remove();
                video?.play();
                setTimeout(() => video?.play(), 500);
                log("Popup removed");
            }

            if (video?.paused) video.play();
        }, 1000);
    }

    function removeAds() {
        log("removeAds()");
        setInterval(() => {
            const video = document.querySelector('video');
            const ad = document.querySelector('.ad-showing');

            // Handle URL changes
            if (window.location.href !== currentUrl) {
                currentUrl = window.location.href;
                removePageAds();
            }

            // Handle YouTube Shorts
            if (window.location.href.includes("shorts")) {
                log("YouTube shorts detected, ignoring...");
                return;
            }

            if (ad) {
                isAdFound = true;
                adLoop++;

                log("Ad detected");

                // Try blocking ad via Ad Center (limited attempts to avoid freezes)
                if (adLoop < 10) {
                    const openAdCenter = document.querySelector('.ytp-ad-button-icon');
                    openAdCenter?.dispatchEvent(clickEvent);

                    const blockAdButton = document.querySelector('[label="Block ad"]');
                    blockAdButton?.dispatchEvent(clickEvent);

                    const confirmBlock = document.querySelector('.Eddif [label="CONTINUE"] button');
                    confirmBlock?.dispatchEvent(clickEvent);

                    const closeAdCenter = document.querySelector('.zBmRhe-Bz112c');
                    closeAdCenter?.dispatchEvent(clickEvent);
                }

                // Hide popup container
                const popupContainer = document.querySelector('body > ytd-app > ytd-popup-container > tp-yt-paper-dialog');
                if (popupContainer && popupContainer.style.display === "") {
                    popupContainer.style.display = 'none';
                }

                // Skip ad by clicking buttons or jumping to end
                const skipButtons = [
                    '.ytp-ad-skip-button-container',
                    '.ytp-ad-skip-button-modern',
                    '.videoAdUiSkipButton',
                    '.ytp-ad-skip-button',
                    '.ytp-ad-skip-button-slot'
                ];

                if (video) {
                    skipButtons.forEach(selector => {
                        document.querySelectorAll(selector).forEach(element => {
                            element.dispatchEvent(clickEvent);
                        });
                    });

                    // Jump to end with slight randomization to avoid detection
                    const randomOffset = Math.random() * 0.4 + 0.1;
                    video.currentTime = video.duration + randomOffset || 0;
                    video.play();
                }

                log("Ad skipped (✔️)");
            } else {
                if (video && video.playbackRate === 10) {
                    video.playbackRate = videoPlayback;
                }

                if (isAdFound) {
                    isAdFound = false;
                    adLoop = 0;
                    if (video && isFinite(videoPlayback)) {
                        if (videoPlayback === 10) videoPlayback = 1;
                        video.playbackRate = videoPlayback;
                    }
                    log("Reset after ad skip");
                } else if (video) {
                    videoPlayback = video.playbackRate;
                }
            }

            // Remove error screen
            const errorScreen = document.querySelector("#error-screen");
            if (errorScreen) errorScreen.remove();
        }, 50);
        removePageAds();
    }

    function removePageAds() {
        const sponsors = document.querySelectorAll("div#player-ads.style-scope.ytd-watch-flexy, div#panels.style-scope.ytd-watch-flexy");
        const style = document.createElement('style');
        style.textContent = 
            ytd-action-companion-ad-renderer, ytd-display-ad-renderer, ytd-video-masthead-ad-advertiser-info-renderer,
            ytd-video-masthead-ad-primary-video-renderer, ytd-in-feed-ad-layout-renderer, ytd-ad-slot-renderer,
            yt-about-this-ad-renderer, yt-mealbar-promo-renderer, ytd-statement-banner-renderer, ytd-banner-promo-renderer-background,
            .ytd-video-masthead-ad-v3-renderer, div#root.style-scope.ytd-display-ad-renderer.yt-simple-endpoint,
            div#sparkles-container.style-scope.ytd-promoted-sparkles-web-renderer, div#main-container.style-scope.ytd-promoted-video-renderer,
            div#player-ads.style-scope.ytd-watch-flexy, ad-slot-renderer, ytm-promoted-sparkles-web-renderer, masthead-ad,
            tp-yt-iron-overlay-backdrop, #masthead-ad { display: none !important; }
        ;
        document.head.appendChild(style);

        sponsors.forEach(element => {
            if (element.id === "rendering-content") {
                element.childNodes.forEach(child => {
                    if (child?.data?.targetId && child.data.targetId !== "engagement-panel-macro-markers-description-chapters") {
                        element.style.display = 'none';
                    }
                });
            }
        });
        log("Removed page ads (✔️)");
    }

    function timestampFix() {
        document.addEventListener('click', event => {
            const target = event.target;
            if (target.classList.contains('yt-core-attributed-string__link') && target.href.includes('&t=')) {
                event.preventDefault();
                const timestamp = target.href.split('&t=')[1].split('s')[0];
                log(Timestamp link clicked: ${timestamp} seconds);
                const video = document.querySelector('video');
                if (video) {
                    video.currentTime = parseInt(timestamp);
                    video.play();
                }
            }
        });
    }

    function checkForUpdate() {
        if (window.top !== window.self || !window.location.href.includes("youtube.com") || hasIgnoredUpdate) return;

        const scriptUrl = 'https://raw.githubusercontent.com/TheRealJoelmatic/RemoveAdblockThing/main/Youtube-Ad-blocker-Reminder-Remover.user.js';
        fetch(scriptUrl)
            .then(response => response.text())
            .then(data => {
                const match = data.match(/@version\s+(\d+\.\d+)/);
                if (!match) {
                    log("Unable to extract version.", "error");
                    return;
                }

                const githubVersion = parseFloat(match[1]);
                const currentVersion = 6.0;
                if (githubVersion <= currentVersion) {
                    log(Latest version: ${githubVersion} = ${currentVersion});
                    return;
                }

                if (config.updateModal.enable && parseFloat(localStorage.getItem('skipRemoveAdblockThingVersion')) !== githubVersion) {
                    const script = document.createElement('script');
                    script.src = 'https://cdn.jsdelivr.net/npm/sweetalert2@11';
                    document.head.appendChild(script);
                    const style = document.createElement('style');
                    style.textContent = '.swal2-container { z-index: 2400; }';
                    document.head.appendChild(style);

                    script.onload = () => {
                        Swal.fire({
                            position: "top-end",
                            backdrop: false,
                            title: 'Remove Adblock Thing: New version available.',
                            text: 'Do you want to update?',
                            showCancelButton: true,
                            showDenyButton: true,
                            confirmButtonText: 'Update',
                            denyButtonText: 'Skip',
                            cancelButtonText: 'Close',
                            timer: config.updateModal.timer,
                            timerProgressBar: true,
                            didOpen: modal => {
                                modal.onmouseenter = Swal.stopTimer;
                                modal.onmouseleave = Swal.resumeTimer;
                            }
                        }).then(result => {
                            if (result.isConfirmed) window.location.replace(scriptUrl);
                            else if (result.isDenied) localStorage.setItem('skipRemoveAdblockThingVersion', githubVersion);
                        });
                    };

                    script.onerror = () => {
                        if (window.confirm("Remove Adblock Thing: A new version is available.")) {
                            window.location.replace(scriptUrl);
                        }
                    };
                } else {
                    if (window.confirm("Remove Adblock Thing: A new version is available.")) {
                        window.location.replace(scriptUrl);
                    }
                }
            })
            .catch(error => log("Update check failed:", "error", error));
        hasIgnoredUpdate = true;
    }

    function log(message, level = 'log', ...args) {
        if (!config.debugMessages) return;
        const prefix = '🔧 Remove Adblock Thing:';
        const msg = ${prefix} ${message};
        switch (level) {
            case 'error': console.error(❌ ${msg}, ...args); break;
            case 'warning': console.warn(⚠️ ${msg}, ...args); break;
            case 'log': console.log(✅ ${msg}, ...args); break;
            default: console.info(ℹ️ ${msg}, ...args);
        }
    }
}
)();
