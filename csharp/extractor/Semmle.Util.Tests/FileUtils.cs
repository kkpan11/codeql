using Xunit;
using Semmle.Util;
using Semmle.Util.Logging;

namespace SemmleTests.Semmle.Util
{
    public class TestFileUtils
    {
        [Fact]
        public void TestConvertPaths()
        {
            Assert.Equal("/tmp/abc.cs", FileUtils.ConvertToUnix(@"\tmp\abc.cs"));
            Assert.Equal("tmp/abc.cs", FileUtils.ConvertToUnix(@"tmp\abc.cs"));

            Assert.Equal(@"\tmp\abc.cs", FileUtils.ConvertToWindows(@"/tmp/abc.cs"));
            Assert.Equal(@"tmp\abc.cs", FileUtils.ConvertToWindows(@"tmp/abc.cs"));

            Assert.Equal(Win32.IsWindows() ? @"foo\bar" : "foo/bar", FileUtils.ConvertToNative("foo/bar"));
        }

        [Fact]
        public void NestedPaths()
        {
            string root1, root2, root3;

            if (Win32.IsWindows())
            {
                root1 = "E:";
                root2 = "e:";
                root3 = @"\";
            }
            else
            {
                root1 = "/E_";
                root2 = "/e_";
                root3 = "/";
            }

            using var logger = new LoggerMock();

            Assert.Equal($@"C:\Temp\source_archive\def.cs", FileUtils.NestPaths(logger, @"C:\Temp\source_archive", "def.cs").Replace('/', '\\'));

            Assert.Equal(@"C:\Temp\source_archive\def.cs", FileUtils.NestPaths(logger, @"C:\Temp\source_archive", "def.cs").Replace('/', '\\'));

            Assert.Equal(@"C:\Temp\source_archive\E_\source\def.cs", FileUtils.NestPaths(logger, @"C:\Temp\source_archive", $@"{root1}\source\def.cs").Replace('/', '\\'));

            Assert.Equal(@"C:\Temp\source_archive\e_\source\def.cs", FileUtils.NestPaths(logger, @"C:\Temp\source_archive", $@"{root2}\source\def.cs").Replace('/', '\\'));

            Assert.Equal(@"C:\Temp\source_archive\source\def.cs", FileUtils.NestPaths(logger, @"C:\Temp\source_archive", $@"{root3}source\def.cs").Replace('/', '\\'));

            Assert.Equal(@"C:\Temp\source_archive\source\def.cs", FileUtils.NestPaths(logger, @"C:\Temp\source_archive", $@"{root3}source\def.cs").Replace('/', '\\'));

            Assert.Equal(@"C:\Temp\source_archive\diskstation\share\source\def.cs", FileUtils.NestPaths(logger, @"C:\Temp\source_archive", $@"{root3}{root3}diskstation\share\source\def.cs").Replace('/', '\\'));
        }

        private sealed class LoggerMock : ILogger
        {
            public void Dispose() { }

            public void Log(Severity s, string text, int? threadId = null) { }
        }
    }
}
