var pdfjsLib = null;
var loaded = false;

function loadPdfJs(cb) {
  if (loaded) { cb(); return; }
  var s = document.createElement("script");
  s.src = "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.4.168/pdf.min.mjs";
  s.type = "module";
  document.head.appendChild(s);
  s.onload = function() {
    import("https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.4.168/pdf.min.mjs").then(function(mod) {
      pdfjsLib = mod;
      pdfjsLib.GlobalWorkerOptions.workerSrc = "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.4.168/pdf.worker.min.mjs";
      loaded = true;
      cb();
    });
  };
}

function renderPdf(url, container) {
  container.innerHTML = "";
  loadPdfJs(function() {
    pdfjsLib.getDocument(url).promise.then(function(pdf) {
      function renderPage(num) {
        if (num > pdf.numPages) return;
        pdf.getPage(num).then(function(page) {
          var canvas = document.createElement("canvas");
          var scale = 1.5;
          var viewport = page.getViewport({ scale: scale });
          canvas.width = viewport.width;
          canvas.height = viewport.height;
          canvas.style.maxWidth = "100%";
          canvas.style.height = "auto";
          canvas.style.marginBottom = "4px";
          container.appendChild(canvas);
          page.render({ canvasContext: canvas.getContext("2d"), viewport: viewport }).promise.then(function() {
            renderPage(num + 1);
          });
        });
      }
      renderPage(1);
    });
  });
}

function isLocalPdf(href) {
  if (!href) return false;
  if (!href.match(/\.pdf$/i)) return false;
  if (href.startsWith("http")) return false;
  return true;
}

document.addEventListener("click", function(e) {
  if (e.button !== 0) return;
  if (e.ctrlKey || e.metaKey || e.shiftKey) return;
  var a = e.target.closest("a");
  if (!a) return;
  var href = a.getAttribute("href") || "";
  if (!isLocalPdf(href)) return;
  e.preventDefault();
  var overlay = document.getElementById("pdf-overlay");
  var viewer = document.getElementById("pdf-viewer");
  overlay.style.display = "block";
  renderPdf(href, viewer);
});

document.getElementById("pdf-close").addEventListener("click", function() {
  var overlay = document.getElementById("pdf-overlay");
  overlay.style.display = "none";
  document.getElementById("pdf-viewer").innerHTML = "";
});

document.getElementById("pdf-overlay").addEventListener("click", function(e) {
  if (e.target === this) {
    this.style.display = "none";
    document.getElementById("pdf-viewer").innerHTML = "";
  }
});
