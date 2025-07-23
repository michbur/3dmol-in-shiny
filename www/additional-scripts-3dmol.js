let viewer;

function initViewer() {
  viewer = $3Dmol.createViewer('viewer', { backgroundColor: 'white' });
  viewer.render();
}

document.addEventListener('DOMContentLoaded', function () {
  initViewer();

  document.getElementById('btn-screenshot').addEventListener('click', () => {
    const canvas = viewer.renderCanvas();
    const url = canvas.toDataURL('image/png');
    const a = document.createElement('a');
    a.href = url;
    a.download = '3dmol_screenshot.png';
    a.click();
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
  viewer.spin();

});

