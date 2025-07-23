let viewer;
let isSpinning = true;

function initViewer() {
  viewer = $3Dmol.createViewer('viewer', { backgroundColor: 'white' });
  viewer.render();
}

document.addEventListener('DOMContentLoaded', function () {
  initViewer();

  document.getElementById('btn-screenshot').addEventListener('click', () => {
    if (!viewer) return;

    try {
      const canvas = viewer.getCanvas();
      if (!canvas) {
        console.error("No canvas found for screenshot.");
        return;
      }

      canvas.toBlob(function(blob) {
        const a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = '3dmol_screenshot.png';
        a.click();
      }, 'image/png');
    } catch (e) {
      console.error("Screenshot failed:", e);
    }
  });

  document.getElementById('toggle-spin').addEventListener('change', (event) => {
    if (!viewer) return;
    isSpinning = event.target.checked;
    viewer.spin(isSpinning);
  });
});


Shiny.addCustomMessageHandler('renderStructure', function(message) {

  viewer.clear();
  viewer.addModel(message.data, 'cif');

  const colorMap = message.colorMap;

  viewer.setStyle({
    cartoon: {
      colorfunc: function(atom) {
        let resi = atom.resi.toString();
        return colorMap[resi] || 'white';
      }
    }
  });

  viewer.zoomTo();
  viewer.render();

  viewer.spin(isSpinning);
});

