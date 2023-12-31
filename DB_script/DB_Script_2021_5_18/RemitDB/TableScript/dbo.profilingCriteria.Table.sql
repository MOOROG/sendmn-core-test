USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[profilingCriteria]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[profilingCriteria](
	[criteriaId] [int] IDENTITY(1,1) NOT NULL,
	[topic] [varchar](200) NOT NULL,
	[minimumScore] [money] NOT NULL,
	[maximumScore] [money] NOT NULL,
	[displayOrder] [int] NOT NULL,
	[createdBy] [varchar](50) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifedDate] [datetime] NULL,
	[isActive] [varchar](1) NULL,
 CONSTRAINT [PK_profilingCriteria] PRIMARY KEY CLUSTERED 
(
	[criteriaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
