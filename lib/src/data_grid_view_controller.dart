class DataGridViewController {
  Function({String fileName, double scale, String reportHeaderText})? generatePdf;
  Function({double scale, String reportHeaderText, String reportSubHeaderText})? printPreview;
  Function({String fileName, String reportHeaderText})? generateXls;
  Function? resetFilterAndSort;
  // Function? printPreview;
  void dispose() {
    generatePdf = null;
    generateXls = null;
    printPreview = null;
  }
}
