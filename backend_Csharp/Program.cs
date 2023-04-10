using System;
using System.Drawing;
using System.IO;
using System.Net;
using System.Text;
using System.Web.Script.Serialization;
using MathNet.Numerics.LinearAlgebra;
using System.Collections.Generic;

namespace server
{
    internal class Program
    {
        static void Main()
        {
            string baseUrl = "http://127.0.0.1:8080/";

            HttpListener listener = new HttpListener();
            listener.Prefixes.Add(baseUrl);
            listener.Start();
            Console.WriteLine($"Server running at {baseUrl}");

            while (true)
            {
                // To Make Sure server do not stop on any unexpected error
                HttpListenerContext context = listener.GetContext();
                string url = context.Request.Url.ToString();
                Console.WriteLine($"Request received for {url}");
                try
                {
                    if (context.Request.HttpMethod == "GET" && url == baseUrl)
                    {
                        dynamic responseData = new { message = "Hello Wolrd" };
                        string responseText = new JavaScriptSerializer().Serialize(responseData);

                        // Send the JSON response back to the client
                        byte[] responseBytes = Encoding.UTF8.GetBytes(responseText);
                        context.Response.ContentType = "application/json";
                        context.Response.ContentLength64 = responseBytes.Length;
                        context.Response.OutputStream.Write(responseBytes, 0, responseBytes.Length);

                    }

                    else if (context.Request.HttpMethod == "POST" && url == $"{baseUrl}svd")
                    {
                        // Starting the time 
                        DateTime start = DateTime.Now;

                        // Read the request body as a string
                        StreamReader reader = new StreamReader(context.Request.InputStream, context.Request.ContentEncoding);
                        string requestBody = reader.ReadToEnd();
                        // Deserialize the JSON request body into a dynamic object
                        dynamic requestData = new JavaScriptSerializer().DeserializeObject(requestBody);
                        // Extract the two numbers from the request data
                        string filePath = requestData["filePath"];
                        Dictionary<string, Vector<double>> projections = GrayscaleConverter.calculateSVDofMatrix(filePath);
                        Vector<double> leftProjection = projections["left"];
                        Vector<double> rightProjection = projections["right"];

                        // End the time
                        DateTime end = DateTime.Now;

                        // total time taken in miliseconds
                        double timeTaken = (end - start).TotalMilliseconds;

                        // create a JSON response object
                        dynamic responseData = new { left = leftProjection, right = rightProjection, time = timeTaken };
                        string responseText = new JavaScriptSerializer().Serialize(responseData);
                        // Send the JSON response back to the client
                        byte[] responseBytes = Encoding.UTF8.GetBytes(responseText);
                        context.Response.ContentType = "application/json";
                        context.Response.ContentLength64 = responseBytes.Length;
                        context.Response.OutputStream.WriteAsync(responseBytes, 0, responseBytes.Length);
                    }
                    else
                    {
                        context.Response.StatusCode = 404;
                    }
                    context.Response.Close();
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.Message);
                    context.Response.StatusCode = 500;
                    dynamic responseData = new { error = e.Message };
                    string responseText = new JavaScriptSerializer().Serialize(responseData);
                    // Send the JSON response back to the client
                    byte[] responseBytes = Encoding.UTF8.GetBytes(responseText);
                    context.Response.ContentType = "application/json";
                    context.Response.ContentLength64 = responseBytes.Length;
                    context.Response.OutputStream.WriteAsync(responseBytes, 0, responseBytes.Length);
                }
            }
        }
    }
}


public class GrayscaleConverter
{

    public static Dictionary<string, Vector<double>> calculateSVDofMatrix(string filePath)

    {   
        Bitmap bmp = new Bitmap(filePath);
        double[,] matrix = new double[bmp.Height, bmp.Width];

        // Loop through the image pixels and calculate their grayscale value
        for (int y = 0; y < bmp.Height; y++)
        {
            for (int x = 0; x < bmp.Width; x++)
            {
                Color pixel = bmp.GetPixel(x, y);
                int grayValue = (int)(0.299 * pixel.R + 0.587 * pixel.G + 0.114 * pixel.B);
                matrix[y, x] = grayValue;
            }
        }

        Matrix<double> inputMatrix = Matrix<double>.Build.DenseOfArray(matrix);

        // Compute the SVD of the input matrix
        var svd = inputMatrix.Svd(true);
        Dictionary<string, Vector<double>> projections = new Dictionary<string, Vector<double>>();

        // Extract the left and right singular vectors
        Vector<double> leftSingularVectors = svd.U.Column(1);
        Vector<double> rightSingularVectors = svd.VT.Row(1);

        // Project the left and right vectors onto the second singular vectors
        // left_projection is equal to the multiplication of transpose of inputMatrix and leftSingularVectors
        Vector<double> leftProjection = inputMatrix.Transpose() * leftSingularVectors;

        // right_projection is equal to the multiplication of inputMatrix and rightSingularVectors
        Vector<double> rightProjection = inputMatrix * rightSingularVectors;

        // Add the projections to the dictionary
        projections.Add("left", leftProjection);
        projections.Add("right", rightProjection);
        return projections;
    }
}

