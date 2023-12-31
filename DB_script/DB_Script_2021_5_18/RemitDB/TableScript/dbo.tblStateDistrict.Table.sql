USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tblStateDistrict]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblStateDistrict](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[stateId] [int] NOT NULL,
	[districtCode] [varchar](15) NULL,
	[disctictName] [nvarchar](100) NOT NULL,
	[isActive] [bit] NULL,
	[createdby] [varchar](50) NOT NULL,
	[modifiedby] [varchar](50) NULL,
	[createdDate] [datetime] NOT NULL,
	[modifieddate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblStateDistrict] ADD  DEFAULT ((1)) FOR [isActive]
GO
ALTER TABLE [dbo].[tblStateDistrict] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
