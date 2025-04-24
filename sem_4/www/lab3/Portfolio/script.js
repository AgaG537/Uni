/*global document, window, console, Image */

document.addEventListener("DOMContentLoaded", function () {
    const hamburger = document.getElementById("hamburger");
    const navList = document.querySelector("nav ul");

    function isMobile() {
        return window.innerWidth < 900;
    }

    hamburger.addEventListener("click", function () {
        if (isMobile()) {
            navList.classList.toggle("active");
        }
    });

    window.addEventListener("resize", function () {
        if (!isMobile()) {
            navList.classList.remove("active");
        }
    });

    loadGallery();
});

function loadImage(src, alt) {
    return new Promise(function (resolve, reject) {
        const img = new Image();
        img.alt = alt;
        img.src = src;
        img.onload = function () {
            resolve(img);
        };
        img.onerror = function () {
            reject(new Error("Image failed to load: " + src));
        };
    });
}

const galleryImages = [
    {alt: "Books", src: "images/book_stack.jpg"},
    {alt: "Biking", src: "images/bike2.jpg"},
    {alt: "Puzzles", src: "images/puzzles-not-finished-cut.jpg"}
];

function loadGallery() {
    const gallery = document.getElementById("dynamic-gallery");

    Promise.all(galleryImages.map(function (img) {
        return loadImage(img.src, img.alt);
    })).then(function (images) {
        images.forEach(function (image) {
            gallery.appendChild(image);
        });
    }).catch(function (err) {
        console.error("Gallery loading error:", err);
        gallery.innerHTML = "<p>Failed to load images.</p>";
    });
}