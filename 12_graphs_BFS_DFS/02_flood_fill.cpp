class Solution {
  public:
    void dfs(vector<vector<int>>& image, int row, int column, int totalRows, int totalColumns, int originalColor, int newColor) {
      if(image[row][column] == newColor) return;

      image[row][column] = newColor;

      int rowTop = row + 1;
      int rowBottom = row - 1;
      int columnLeft = column - 1;
      int columnRight = column + 1;

      //check top
      if(rowTop < totalRows && image[rowTop][column] == originalColor) dfs(image, rowTop, column, totalRows, totalColumns, originalColor, newColor);

      //check bottom
      if(rowBottom >= 0 && image[rowBottom][column] == originalColor) dfs(image, rowBottom, column, totalRows, totalColumns, originalColor, newColor);

      //check left
      if(columnLeft >= 0 && image[row][columnLeft] == originalColor) dfs(image, row, columnLeft, totalRows, totalColumns, originalColor, newColor);

      //check right
      if(columnRight < totalColumns && image[row][columnRight] == originalColor) dfs(image, row, columnRight, totalRows, totalColumns, originalColor, newColor);

    }
    
      
    vector<vector<int>> floodFill(vector<vector<int>>& image, int sr, int sc, int newColor) {
        // code here
        int originalColor = image[sr][sc];
        int totalRows = image.size();
        int totalColumns = image[0].size();

        dfs(image, sr, sc, totalRows, totalColumns, originalColor, newColor);
        return image;
    }
};